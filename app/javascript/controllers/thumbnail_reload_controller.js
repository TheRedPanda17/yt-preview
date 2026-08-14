import { Controller } from "@hotwired/stimulus"

// Safari sometimes paints voting thumbnails as broken "?" icons after Turbo
// navigations even though the image URL is valid. Re-assigning src forces a
// retry once the layout has settled.
export default class extends Controller {
  connect() {
    requestAnimationFrame(() => this.reloadBrokenImages())
  }

  reloadBrokenImages() {
    this.element.querySelectorAll("img").forEach((img) => {
      if (!(img.complete && img.naturalWidth === 0)) return
      if (!img.getAttribute("src")) return

      const src = img.currentSrc || img.src
      img.src = ""
      img.src = src
    })
  }
}
