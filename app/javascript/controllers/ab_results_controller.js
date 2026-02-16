import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["abCard", "winnerCard", "abInputs", "winnerInput"]

  connect() {
    this.selectedIds = []
    this.winnerId = null

    this.abCardTargets.forEach(card => {
      if (card.dataset.preselected === "true") {
        this.selectedIds.push(card.dataset.pairId)
      }
    })

    this.winnerCardTargets.forEach(card => {
      if (card.dataset.preselected === "true") {
        this.winnerId = card.dataset.pairId
      }
    })

    this.render()
  }

  toggleAb(event) {
    const card = event.currentTarget
    const pairId = card.dataset.pairId
    const idx = this.selectedIds.indexOf(pairId)

    if (idx !== -1) {
      this.selectedIds.splice(idx, 1)
    } else {
      this.selectedIds.push(pairId)
    }

    this.render()
  }

  selectWinner(event) {
    const card = event.currentTarget
    const pairId = card.dataset.pairId

    if (this.winnerId === pairId) {
      this.winnerId = null
    } else {
      this.winnerId = pairId
    }

    this.render()
  }

  clearWinner() {
    this.winnerId = null
    this.render()
  }

  render() {
    this.abCardTargets.forEach(card => {
      const isSelected = this.selectedIds.includes(card.dataset.pairId)
      const badge = card.querySelector("[data-ab-badge]")
      const overlay = card.querySelector("[data-ab-overlay]")

      if (isSelected) {
        if (badge) badge.classList.remove("hidden")
        if (overlay) overlay.classList.remove("hidden")
      } else {
        if (badge) badge.classList.add("hidden")
        if (overlay) overlay.classList.add("hidden")
      }
    })

    this.winnerCardTargets.forEach(card => {
      const isWinner = this.winnerId === card.dataset.pairId
      const badge = card.querySelector("[data-winner-badge]")
      const overlay = card.querySelector("[data-winner-overlay]")

      if (isWinner) {
        if (badge) badge.classList.remove("hidden")
        if (overlay) overlay.classList.remove("hidden")
      } else {
        if (badge) badge.classList.add("hidden")
        if (overlay) overlay.classList.add("hidden")
      }
    })

    this.abInputsTarget.innerHTML = ""
    this.selectedIds.forEach(id => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "ab_selected_pair_ids[]"
      input.value = id
      this.abInputsTarget.appendChild(input)
    })

    this.winnerInputTarget.value = this.winnerId || ""
  }
}
