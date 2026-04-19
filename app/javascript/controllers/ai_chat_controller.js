import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values  = { url: String }
  static targets = ["messages", "input", "submit", "loading"]

  connect() {
    this.history = []
  }

  async send() {
    const text = this.inputTarget.value.trim()
    if (!text || this.submitTarget.disabled) return

    this.appendMessage("user", text)
    this.history.push({ role: "user", content: text })
    this.inputTarget.value = ""
    this.setLoading(true)

    try {
      const res = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || ""
        },
        body: JSON.stringify({ messages: this.history })
      })
      const data = await res.json()

      if (data.message) {
        this.appendMessage("assistant", data.message)
        this.history.push({ role: "assistant", content: data.message })
      } else {
        this.appendMessage("error", data.error || "エラーが発生しました")
      }
    } catch {
      this.appendMessage("error", "通信エラーが発生しました")
    } finally {
      this.setLoading(false)
    }
  }

  keydown(event) {
    if (event.key === "Enter" && (event.ctrlKey || event.metaKey)) {
      event.preventDefault()
      this.send()
    }
  }

  appendMessage(role, text) {
    const wrap = document.createElement("div")

    if (role === "user") {
      wrap.style.cssText = "display:flex; justify-content:flex-end;"
      const bubble = document.createElement("div")
      bubble.style.cssText = "max-width:80%; background:#6366f1; color:white; border-radius:18px 18px 4px 18px; padding:12px 16px; font-size:14px; line-height:1.6; white-space:pre-wrap; word-break:break-word;"
      bubble.textContent = text
      wrap.appendChild(bubble)
    } else if (role === "assistant") {
      wrap.style.cssText = "display:flex; justify-content:flex-start; gap:10px;"
      const icon = document.createElement("div")
      icon.style.cssText = "width:32px; height:32px; border-radius:10px; background:#f3f4f6; display:flex; align-items:center; justify-content:center; flex-shrink:0; font-size:16px; margin-top:2px;"
      icon.textContent = "🤖"
      const bubble = document.createElement("div")
      bubble.style.cssText = "max-width:85%; background:white; border:1px solid #e5e7eb; border-radius:4px 18px 18px 18px; padding:14px 16px; font-size:14px; line-height:1.7; white-space:pre-wrap; word-break:break-word; box-shadow:0 1px 3px rgba(0,0,0,0.06);"
      bubble.textContent = text
      wrap.appendChild(icon)
      wrap.appendChild(bubble)
    } else {
      wrap.style.cssText = "display:flex; justify-content:center;"
      const bubble = document.createElement("div")
      bubble.style.cssText = "background:#fef2f2; color:#dc2626; border-radius:12px; padding:10px 16px; font-size:13px;"
      bubble.textContent = text
      wrap.appendChild(bubble)
    }

    this.messagesTarget.appendChild(wrap)
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  setLoading(loading) {
    this.submitTarget.disabled     = loading
    this.loadingTarget.style.display = loading ? "flex" : "none"
  }
}
