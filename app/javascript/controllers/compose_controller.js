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

function addThumbnailToDB(db, videoId, name, blob) {
  return new Promise((resolve, reject) => {
    const tx = db.transaction(STORE_NAME, "readwrite")
    const store = tx.objectStore(STORE_NAME)
    const request = store.add({ videoId, name, blob })
    request.onsuccess = () => resolve(request.result)
    request.onerror = () => reject(request.error)
  })
}

function removeThumbnailFromDB(db, id) {
  return new Promise((resolve, reject) => {
    const tx = db.transaction(STORE_NAME, "readwrite")
    const store = tx.objectStore(STORE_NAME)
    const request = store.delete(id)
    request.onsuccess = () => resolve()
    request.onerror = () => reject(request.error)
  })
}

export default class extends Controller {
  static targets = [
    "fileInput", "thumbnailList", "titleInput", "titleList",
    "emptyState", "previewSection", "previewThumbnail", "previewTitle",
    "comboLabel", "modal", "variantButtons",
    "newVariantInput", "createVariantBtn", "variantError"
  ]

  static values = {
    videoId: Number,
    variants: Array,
    csrf: String,
    createUrl: String,
    createVariantUrl: String
  }

  async connect() {
    this.thumbnails = []
    this.titles = []
    this.thumbIndex = 0
    this.titleIndex = 0
    this.db = await openDB()
    this.restoreState()
  }

  disconnect() {
    this.thumbnails.forEach(t => URL.revokeObjectURL(t.url))
    if (this.db) this.db.close()
  }

  async restoreState() {
    const savedTitles = localStorage.getItem(this.titlesKey)
    if (savedTitles) {
      try { this.titles = JSON.parse(savedTitles) } catch (e) { this.titles = [] }
    }

    const records = await loadThumbnails(this.db, this.videoIdValue)
    records.forEach(record => {
      const url = URL.createObjectURL(record.blob)
      this.thumbnails.push({ dbId: record.id, file: new File([record.blob], record.name, { type: record.blob.type }), url, name: record.name })
    })

    this.renderThumbnailList()
    this.renderTitleList()
    this.updatePreview()
  }

  get titlesKey() {
    return `compose_titles_${this.videoIdValue}`
  }

  saveTitles() {
    localStorage.setItem(this.titlesKey, JSON.stringify(this.titles))
  }

  async addThumbnails(event) {
    const files = Array.from(event.target.files)
    for (const file of files) {
      const blob = new Blob([await file.arrayBuffer()], { type: file.type })
      const dbId = await addThumbnailToDB(this.db, this.videoIdValue, file.name, blob)
      const url = URL.createObjectURL(blob)
      this.thumbnails.push({ dbId, file, url, name: file.name })
    }
    event.target.value = ""
    this.renderThumbnailList()
    this.updatePreview()
  }

  async removeThumbnail(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    const thumb = this.thumbnails[index]
    URL.revokeObjectURL(thumb.url)
    if (thumb.dbId) await removeThumbnailFromDB(this.db, thumb.dbId)
    this.thumbnails.splice(index, 1)
    if (this.thumbIndex >= this.thumbnails.length) {
      this.thumbIndex = Math.max(0, this.thumbnails.length - 1)
    }
    this.renderThumbnailList()
    this.updatePreview()
  }

  addTitle(event) {
    if (event.type === "keydown" && event.key !== "Enter") return
    event.preventDefault()

    const input = this.titleInputTarget
    const title = input.value.trim()
    if (!title) return

    this.titles.push(title)
    input.value = ""
    this.saveTitles()
    this.renderTitleList()
    this.updatePreview()
  }

  removeTitle(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.titles.splice(index, 1)
    if (this.titleIndex >= this.titles.length) {
      this.titleIndex = Math.max(0, this.titles.length - 1)
    }
    this.saveTitles()
    this.renderTitleList()
    this.updatePreview()
  }

  prevThumbnail() {
    if (this.thumbnails.length === 0) return
    this.thumbIndex = (this.thumbIndex - 1 + this.thumbnails.length) % this.thumbnails.length
    this.updatePreview()
  }

  nextThumbnail() {
    if (this.thumbnails.length === 0) return
    this.thumbIndex = (this.thumbIndex + 1) % this.thumbnails.length
    this.updatePreview()
  }

  prevTitle() {
    if (this.titles.length === 0) return
    this.titleIndex = (this.titleIndex - 1 + this.titles.length) % this.titles.length
    this.updatePreview()
  }

  nextTitle() {
    if (this.titles.length === 0) return
    this.titleIndex = (this.titleIndex + 1) % this.titles.length
    this.updatePreview()
  }

  renderThumbnailList() {
    const container = this.thumbnailListTarget
    container.innerHTML = ""

    this.thumbnails.forEach((thumb, i) => {
      const wrapper = document.createElement("div")
      wrapper.className = "relative group"

      const img = document.createElement("img")
      img.src = thumb.url
      img.className = `w-16 h-10 object-cover rounded-md border-2 cursor-pointer transition ${
        i === this.thumbIndex ? "border-red-500 shadow-sm" : "border-gray-200 hover:border-gray-300"
      }`
      img.addEventListener("click", () => {
        this.thumbIndex = i
        this.updatePreview()
        this.renderThumbnailList()
      })

      const removeBtn = document.createElement("button")
      removeBtn.type = "button"
      removeBtn.className = "absolute -top-1.5 -right-1.5 w-4 h-4 bg-red-500 text-white rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition text-xs leading-none cursor-pointer"
      removeBtn.innerHTML = "&times;"
      removeBtn.dataset.index = i
      removeBtn.addEventListener("click", (e) => this.removeThumbnail(e))

      wrapper.appendChild(img)
      wrapper.appendChild(removeBtn)
      container.appendChild(wrapper)
    })
  }

  renderTitleList() {
    const container = this.titleListTarget
    container.innerHTML = ""

    this.titles.forEach((title, i) => {
      const wrapper = document.createElement("div")
      wrapper.className = `flex items-center gap-2 px-3 py-1.5 rounded-lg cursor-pointer transition text-sm ${
        i === this.titleIndex
          ? "bg-red-50 border border-red-200 text-red-800"
          : "bg-gray-50 border border-gray-200 text-gray-700 hover:bg-gray-100"
      }`
      wrapper.addEventListener("click", () => {
        this.titleIndex = i
        this.updatePreview()
        this.renderTitleList()
      })

      const text = document.createElement("span")
      text.className = "flex-1 truncate"
      text.textContent = title

      const removeBtn = document.createElement("button")
      removeBtn.type = "button"
      removeBtn.className = "text-gray-400 hover:text-red-500 flex-shrink-0 cursor-pointer"
      removeBtn.innerHTML = '<svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>'
      removeBtn.dataset.index = i
      removeBtn.addEventListener("click", (e) => {
        e.stopPropagation()
        this.removeTitle(e)
      })

      wrapper.appendChild(text)
      wrapper.appendChild(removeBtn)
      container.appendChild(wrapper)
    })
  }

  updatePreview() {
    const hasContent = this.thumbnails.length > 0 && this.titles.length > 0

    if (hasContent) {
      this.emptyStateTarget.classList.add("hidden")
      this.previewSectionTarget.classList.remove("hidden")

      this.previewThumbnailTarget.src = this.thumbnails[this.thumbIndex].url
      this.previewTitleTarget.textContent = this.titles[this.titleIndex]

      this.comboLabelTarget.textContent =
        `Thumbnail ${this.thumbIndex + 1}/${this.thumbnails.length} · Title ${this.titleIndex + 1}/${this.titles.length}`
    } else {
      this.emptyStateTarget.classList.remove("hidden")
      this.previewSectionTarget.classList.add("hidden")
    }
  }

  openVariantModal() {
    const variants = this.variantsValue
    const container = this.variantButtonsTarget
    container.innerHTML = ""

    if (variants.length === 0) {
      container.innerHTML = '<p class="text-sm text-gray-500 text-center py-4">No variants yet. Create one below.</p>'
    } else {
      variants.forEach(variant => {
        const btn = document.createElement("button")
        btn.type = "button"
        btn.className = "w-full text-left px-4 py-3 rounded-lg border border-gray-200 hover:border-red-300 hover:bg-red-50 transition cursor-pointer flex items-center justify-between group"
        btn.innerHTML = `
          <span class="font-medium text-gray-900">${this.escapeHtml(variant.name)}</span>
          <svg class="w-4 h-4 text-gray-400 group-hover:text-red-500 transition" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
        `
        btn.addEventListener("click", () => this.submitPair(variant.id))
        container.appendChild(btn)
      })
    }

    this.modalTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }

  async createVariant(event) {
    if (event.type === "keydown" && event.key !== "Enter") return
    event.preventDefault()

    const input = this.newVariantInputTarget
    const name = input.value.trim()
    if (!name) return

    const errorEl = this.variantErrorTarget
    errorEl.classList.add("hidden")
    this.createVariantBtnTarget.disabled = true
    this.createVariantBtnTarget.textContent = "Creating…"

    try {
      const response = await fetch(this.createVariantUrlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": this.csrfValue,
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: JSON.stringify({ name })
      })

      if (response.ok) {
        const variant = await response.json()
        const variants = this.variantsValue
        variants.push(variant)
        this.variantsValue = variants
        input.value = ""
        this.submitPair(variant.id)
      } else {
        const data = await response.json()
        errorEl.textContent = data.error || "Could not create variant"
        errorEl.classList.remove("hidden")
      }
    } catch (error) {
      errorEl.textContent = "Something went wrong. Please try again."
      errorEl.classList.remove("hidden")
    } finally {
      this.createVariantBtnTarget.disabled = false
      this.createVariantBtnTarget.textContent = "Create & Use"
    }
  }

  closeModal() {
    this.modalTarget.classList.add("hidden")
    document.body.style.overflow = ""
    this.variantErrorTarget.classList.add("hidden")
    this.newVariantInputTarget.value = ""
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  async submitPair(variantId) {
    const formData = new FormData()
    formData.append("variant_id", variantId)
    formData.append("title", this.titles[this.titleIndex])
    formData.append("thumbnail", this.thumbnails[this.thumbIndex].file)

    try {
      const response = await fetch(this.createUrlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": this.csrfValue,
          "Accept": "text/html"
        },
        body: formData
      })

      if (response.redirected) {
        window.location.href = response.url
      } else {
        window.location.reload()
      }
    } catch (error) {
      alert("Something went wrong. Please try again.")
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
