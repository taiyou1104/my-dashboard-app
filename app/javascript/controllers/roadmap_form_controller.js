import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["durationField", "hoursField", "durationGroup", "hoursGroup"]

  hoursChanged() {
    const filled = this.hoursFieldTarget.value.trim() !== ""
    this.durationFieldTarget.disabled = filled
    this.durationGroupTarget.style.opacity = filled ? "0.4" : "1"
    if (filled) this.durationFieldTarget.value = ""
  }

  durationChanged() {
    const filled = this.durationFieldTarget.value.trim() !== ""
    this.hoursFieldTarget.disabled = filled
    this.hoursGroupTarget.style.opacity = filled ? "0.4" : "1"
    if (filled) this.hoursFieldTarget.value = ""
  }

  setDuration(event) {
    this.durationFieldTarget.value = event.params.days
    this.durationChanged()
  }
}
