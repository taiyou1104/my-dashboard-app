import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "overlay"]

  submit() {
    if (this.hasButtonTarget) this.buttonTarget.disabled = true
    if (this.hasOverlayTarget) this.overlayTarget.classList.remove("hidden")
  }
}
