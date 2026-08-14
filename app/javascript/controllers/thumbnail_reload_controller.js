import { Controller } from "@hotwired/stimulus"

// Safari can paint a cached broken "?" for an image that later loads fine on
// refresh. Retry with a unique query param so the request is not served from
// the broken in-memory cache.
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
    if (!img) return

    const tries = parseInt(img.dataset.retryCount || "0", 10)
    if (tries >= 2) return

    const src = img.getAttribute("src")
    if (!src) return

    img.dataset.retryCount = String(tries + 1)
    const url = new URL(src, window.location.origin)
    url.searchParams.set("_r", String(Date.now()))
    img.src = url.toString()
  }
}
