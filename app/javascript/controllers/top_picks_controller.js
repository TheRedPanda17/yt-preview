import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "hiddenInputs", "counter", "submitBtn"]
  static values = { max: { type: Number, default: 3 } }

  connect() {
    this.ranked = []

    const preselected = this.cardTargets
      .filter(card => card.dataset.preselected === "true")
      .sort((a, b) => parseInt(a.dataset.preselectedPosition || 0) - parseInt(b.dataset.preselectedPosition || 0))

    preselected.forEach(card => this.ranked.push(card.dataset.pairId))
    this.render()
  }

  toggle(event) {
    const card = event.currentTarget
    const pairId = card.dataset.pairId
    const idx = this.ranked.indexOf(pairId)

    if (idx !== -1) {
      this.ranked.splice(idx, 1)
    } else if (this.ranked.length < this.maxValue) {
      this.ranked.push(pairId)
    }

    this.render()
  }

  render() {
    const atMax = this.ranked.length >= this.maxValue

    this.cardTargets.forEach(card => {
      const rank = this.ranked.indexOf(card.dataset.pairId)
      const isSelected = rank !== -1
      const badge = card.querySelector("[data-checkmark]")
      const overlay = card.querySelector("[data-overlay]")
      const rankLabel = card.querySelector("[data-rank-label]")

      if (isSelected) {
        card.classList.remove("opacity-50", "pointer-events-none")
        if (badge) badge.classList.remove("hidden")
        if (overlay) overlay.classList.remove("hidden")
        if (rankLabel) rankLabel.textContent = `#${rank + 1}`
      } else {
        if (badge) badge.classList.add("hidden")
        if (overlay) overlay.classList.add("hidden")
        card.classList.toggle("opacity-50", atMax)
        card.classList.toggle("pointer-events-none", atMax)
      }
    })

    this.hiddenInputsTarget.innerHTML = ""
    this.ranked.forEach(pairId => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "pair_ids[]"
      input.value = pairId
      this.hiddenInputsTarget.appendChild(input)
    })

    this.counterTarget.textContent = `${this.ranked.length}/${this.maxValue} ranked`

    if (this.hasSubmitBtnTarget) {
      const ready = this.ranked.length === this.maxValue
      this.submitBtnTarget.disabled = !ready
      this.submitBtnTarget.classList.toggle("opacity-50", !ready)
      this.submitBtnTarget.classList.toggle("cursor-not-allowed", !ready)
      this.submitBtnTarget.classList.toggle("cursor-pointer", ready)
    }
  }
}
