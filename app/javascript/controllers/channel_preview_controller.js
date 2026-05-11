import { Controller } from "@hotwired/stimulus"

const DB_NAME = "yt_preview_compose"
const DB_VERSION = 1
const STORE_NAME = "thumbnails"

function openDB() {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, DB_VERSION)
    request.onupgradeneeded = () => {
      const db = request.result
      if (!db.objectStoreNames.contains(STORE_NAME)) {
        const store = db.createObjectStore(STORE_NAME, { keyPath: "id", autoIncrement: true })
        store.createIndex("videoId", "videoId", { unique: false })
      }
    }
    request.onsuccess = () => resolve(request.result)
    request.onerror = () => reject(request.error)
  })
}

function loadThumbnails(db, videoId) {
  return new Promise((resolve, reject) => {
    const tx = db.transaction(STORE_NAME, "readonly")
    const store = tx.objectStore(STORE_NAME)
    const index = store.index("videoId")
    const request = index.getAll(videoId)
    request.onsuccess = () => resolve(request.result)
    request.onerror = () => reject(request.error)
  })
}

export default class extends Controller {
  static targets = [
    "previewImage", "previewPlaceholder", "previewTitle", "previewDuration",
    "previewMeta", "candidateTray", "pendingTray", "pendingEmpty", "selectedLabel"
  ]

  static values = {
    videoId: Number,
    savedCandidates: Array,
    defaultTitle: String,
    defaultViews: String,
    defaultDuration: String
  }

  async connect() {
    this.objectUrls = []
    this.candidates = this.savedCandidatesValue.map((candidate) => ({ ...candidate, source: "Saved pair" }))
    this.renderSavedCandidates()
    this.selectCandidate(this.candidates[0])
    await this.loadPendingCandidates()
  }

  disconnect() {
    this.objectUrls.forEach((url) => URL.revokeObjectURL(url))
    if (this.db) this.db.close()
  }

  renderSavedCandidates() {
    this.candidateTrayTarget.innerHTML = ""

    this.candidates.forEach((candidate, index) => {
      this.candidateTrayTarget.appendChild(this.buildCandidateButton(candidate, index))
    })
  }

  async loadPendingCandidates() {
    const titles = this.pendingTitles()
    this.db = await openDB()
    const records = await loadThumbnails(this.db, this.videoIdValue)

    if (titles.length === 0 || records.length === 0) {
      this.pendingEmptyTarget.classList.remove("hidden")
      return
    }

    this.pendingEmptyTarget.classList.add("hidden")
    const pendingCandidates = []

    records.forEach((record, thumbnailIndex) => {
      const url = URL.createObjectURL(record.blob)
      this.objectUrls.push(url)

      titles.forEach((title, titleIndex) => {
        pendingCandidates.push({
          title,
          thumbnailUrl: url,
          views: this.defaultViewsValue,
          duration: this.defaultDurationValue,
          source: "Pending draft",
          label: `Draft ${thumbnailIndex + 1}.${titleIndex + 1}`
        })
      })
    })

    pendingCandidates.forEach((candidate, index) => {
      this.pendingTrayTarget.appendChild(this.buildCandidateButton(candidate, index, true))
    })

    if (!this.candidates.length) this.selectCandidate(pendingCandidates[0])
  }

  pendingTitles() {
    const savedTitles = localStorage.getItem(`compose_titles_${this.videoIdValue}`)
    if (!savedTitles) return []

    try {
      return JSON.parse(savedTitles).filter((title) => title && title.trim().length > 0)
    } catch (_error) {
      return []
    }
  }

  buildCandidateButton(candidate, index, pending = false) {
    const button = document.createElement("button")
    button.type = "button"
    button.className = "group flex w-56 flex-shrink-0 gap-3 rounded-xl border border-neutral-800 bg-neutral-950 p-2 text-left transition hover:border-white/40 hover:bg-neutral-900"
    button.dataset.index = index
    button.dataset.pending = pending
    button.candidate = candidate
    button.addEventListener("click", () => this.selectCandidate(candidate))

    button.innerHTML = `
      <div class="relative h-16 w-28 flex-shrink-0 overflow-hidden rounded-lg bg-neutral-800">
        <img src="${this.escapeHtml(candidate.thumbnailUrl)}" alt="" class="h-full w-full object-cover">
        ${candidate.duration ? `<span class="absolute bottom-1 right-1 rounded bg-black/85 px-1 text-[10px] font-medium leading-4 text-white">${this.escapeHtml(candidate.duration)}</span>` : ""}
      </div>
      <div class="min-w-0 flex-1">
        <p class="line-clamp-2 text-xs font-medium leading-4 text-white">${this.escapeHtml(candidate.title)}</p>
        <p class="mt-1 text-[11px] text-neutral-400">${this.escapeHtml(candidate.label || candidate.source)}</p>
      </div>
    `

    return button
  }

  selectCandidate(candidate) {
    if (!candidate) {
      this.previewTitleTarget.textContent = this.defaultTitleValue
      this.previewMetaTarget.textContent = `${this.defaultViewsValue} • Preview`
      this.previewImageTarget.removeAttribute("src")
      this.previewPlaceholderTarget.classList.remove("hidden")
      this.previewDurationTarget.classList.add("hidden")
      this.selectedLabelTarget.textContent = "Add a pair or pending draft to preview it."
      return
    }

    this.previewImageTarget.src = candidate.thumbnailUrl
    this.previewPlaceholderTarget.classList.add("hidden")
    this.previewTitleTarget.textContent = candidate.title
    this.previewMetaTarget.textContent = `${candidate.views || this.defaultViewsValue} • Preview`
    this.selectedLabelTarget.textContent = `${candidate.source}: ${candidate.title}`

    if (candidate.duration) {
      this.previewDurationTarget.textContent = candidate.duration
      this.previewDurationTarget.classList.remove("hidden")
    } else {
      this.previewDurationTarget.classList.add("hidden")
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text || ""
    return div.innerHTML
  }
}
