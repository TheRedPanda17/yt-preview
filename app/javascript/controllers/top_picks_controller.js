import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "hiddenInputs", "counter", "submitBtn"]
  static values = { max: { type: Number, default: 3 } }

  connect() {
    // Ordered array of pair IDs — index = rank (0-based, displayed as 1-based)
    this.ranked = []

    // Restore pre-selected cards in order (by data-preselected-position)
    const preselected = this.cardTargets
      .filter(card => card.dataset.preselected === "true")
      .sort((a, b) => parseInt(a.dataset.preselectedPosition || 0) - parseInt(b.dataset.preselectedPosition || 0))

    preselected.forEach(card => {
      this.ranked.push(card.dataset.pairId)
    })

    this.render()
  }

  toggle(event) {
    const card = event.currentTarget
    const pairId = card.dataset.pairId
    const idx = this.ranked.indexOf(pairId)

    if (idx !== -1) {
      // Deselect — remove from ranked list
      this.ranked.splice(idx, 1)
    } else if (this.ranked.length < this.maxValue) {
      // Select — append to end (next rank)
      this.ranked.push(pairId)
    }

    this.render()
  }

  render() {
    const atMax = this.ranked.length >= this.maxValue

    // Update card visuals
    this.cardTargets.forEach(card => {
      const pairId = card.dataset.pairId
      const rank = this.ranked.indexOf(pairId)
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

        if (atMax) {
          card.classList.add("opacity-50", "pointer-events-none")
        } else {
          card.classList.remove("opacity-50", "pointer-events-none")
        }
      }
    })

    // Update hidden inputs (in rank order)
    this.hiddenInputsTarget.innerHTML = ""
    this.ranked.forEach(pairId => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "pair_ids[]"
      input.value = pairId
      this.hiddenInputsTarget.appendChild(input)
    })

    // Update counter
    this.counterTarget.textContent = `${this.ranked.length}/${this.maxValue} ranked`

    // Update submit button
    if (this.ranked.length === this.maxValue) {
      this.submitBtnTarget.disabled = false
      this.submitBtnTarget.classList.remove("opacity-50", "cursor-not-allowed")
      this.submitBtnTarget.classList.add("hover:bg-[#0051b5]", "cursor-pointer")
    } else {
      this.submitBtnTarget.disabled = true
      this.submitBtnTarget.classList.add("opacity-50", "cursor-not-allowed")
      this.submitBtnTarget.classList.remove("hover:bg-[#0051b5]", "cursor-pointer")
    }
  }
}
