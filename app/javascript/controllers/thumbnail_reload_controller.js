import { Controller } from "@hotwired/stimulus"

// Last-resort retry if Safari still paints a broken "?" after a Turbo visit.
export default class extends Controller {
  connect() {
    this.element.querySelectorAll("img").forEach((img) => {
      img.addEventListener("error", this.retry)
      if (img.complete && img.naturalWidth === 0) this.retry({ currentTarget: img })
    })
  }

  disconnect() {
    this.element.querySelectorAll("img").forEach((img) => {
      img.removeEventListener("error", this.retry)
    })
  }

  retry = (event) => {
    const img = event.currentTarget
    if (!img || img.dataset.retrying === "true") return

    const src = img.getAttribute("src")
    if (!src) return

    img.dataset.retrying = "true"
    img.removeAttribute("src")
    requestAnimationFrame(() => {
      img.src = src
      delete img.dataset.retrying
    })
  }
}
