import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["option"]

  connect() {
    this.update()
  }

  update() {
    this.optionTargets.forEach((option) => {
      const radio = option.querySelector("input[type=radio]")
      const display = option.querySelector("[data-display]")
      const value = parseInt(radio.value)

      if (radio.checked) {
        let bg, border
        if (value <= 3) { bg = "#ef4444"; border = "#ef4444" }
        else if (value <= 5) { bg = "#f59e0b"; border = "#f59e0b" }
        else if (value <= 7) { bg = "#eab308"; border = "#eab308" }
        else { bg = "#22c55e"; border = "#22c55e" }

        display.style.backgroundColor = bg
        display.style.borderColor = border
        display.style.color = "#ffffff"
      } else {
        display.style.backgroundColor = ""
        display.style.borderColor = ""
        display.style.color = ""
      }
    })
  }
}
