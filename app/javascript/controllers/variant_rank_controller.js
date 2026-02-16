import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["variant", "submitBtn"]
  static values = { total: Number, url: String, token: String }

  connect() {
    this.ranked = []

    const preselected = this.variantTargets
      .filter(v => v.dataset.preselectedPosition && v.dataset.preselectedPosition !== "0")
      .sort((a, b) => parseInt(a.dataset.preselectedPosition) - parseInt(b.dataset.preselectedPosition))

    preselected.forEach(v => this.ranked.push(v.dataset.variantId))
    this.render()
  }

  toggle(event) {
    const variantEl = event.currentTarget.closest("[data-variant-rank-target='variant']")
    if (!variantEl) return

    const variantId = variantEl.dataset.variantId
    const idx = this.ranked.indexOf(variantId)

    if (idx !== -1) {
      this.ranked.splice(idx, 1)
    } else if (this.ranked.length < this.totalValue) {
      this.ranked.push(variantId)
    }

    this.render()
  }

  submit() {
    if (this.ranked.length < this.totalValue) return

    const form = document.createElement("form")
    form.method = "POST"
    form.action = this.urlValue
    form.style.display = "none"

    const token = document.createElement("input")
    token.type = "hidden"
    token.name = "authenticity_token"
    token.value = this.tokenValue
    form.appendChild(token)

    this.ranked.forEach(id => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "variant_ids[]"
      input.value = id
      form.appendChild(input)
    })

    document.body.appendChild(form)
    form.submit()
  }

  render() {
    const allRanked = this.ranked.length >= this.totalValue

    this.variantTargets.forEach(el => {
      const variantId = el.dataset.variantId
      const rank = this.ranked.indexOf(variantId)
      const isRanked = rank !== -1
      const badge = el.querySelector("[data-rank-badge]")
      const btn = el.querySelector("button[data-action='click->variant-rank#toggle']")

      if (badge) {
        if (isRanked) {
          badge.textContent = `#${rank + 1}`
          badge.classList.remove("hidden", "bg-[#e5e5e5]", "text-[#606060]")
          badge.classList.add("inline-flex", "bg-[#065fd4]", "text-white")
        } else {
          badge.textContent = "—"
          badge.classList.remove("inline-flex", "bg-[#065fd4]", "text-white")
          badge.classList.add("hidden", "bg-[#e5e5e5]", "text-[#606060]")
        }
      }

      if (btn) {
        btn.innerHTML = isRanked ? `#${rank + 1} — click to change` : "Click to rank"
      }
    })

    if (this.hasSubmitBtnTarget) {
      this.submitBtnTarget.disabled = !allRanked
      this.submitBtnTarget.classList.toggle("opacity-50", !allRanked)
      this.submitBtnTarget.classList.toggle("cursor-not-allowed", !allRanked)
      this.submitBtnTarget.classList.toggle("cursor-pointer", allRanked)
    }
  }
}
