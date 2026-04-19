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

    this.removeEmptyState()
    this.appendMessage("user", text)
    this.history.push({ role: "user", content: text })
    this.inputTarget.value = ""
    this.autoResize()
    this.setLoading(true)
    this.scrollBottom()

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
      this.scrollBottom()
    }
  }

  keydown(event) {
    if (event.key === "Enter" && (event.ctrlKey || event.metaKey)) {
      event.preventDefault()
      this.send()
    }
  }

  autoResize() {
    const ta = this.inputTarget
    ta.style.height = "auto"
    ta.style.height = Math.min(ta.scrollHeight, 160) + "px"
  }

  appendMessage(role, text) {
    const wrap = document.createElement("div")
    wrap.style.cssText = "max-width:768px; margin:0 auto 16px;"

    if (role === "user") {
      wrap.innerHTML = `
        <div style="display:flex; justify-content:flex-end;">
          <div style="max-width:78%; background:#6366f1; color:white; border-radius:18px 18px 4px 18px; padding:13px 17px; font-size:14px; line-height:1.7; white-space:pre-wrap; word-break:break-word; box-shadow:0 2px 8px rgba(99,102,241,0.25);">
            ${this.escape(text)}
          </div>
        </div>`
    } else if (role === "assistant") {
      wrap.innerHTML = `
        <div style="display:flex; align-items:flex-start; gap:10px;">
          <div style="width:34px; height:34px; border-radius:11px; background:#f3f4f6; display:flex; align-items:center; justify-content:center; font-size:18px; flex-shrink:0; margin-top:2px;">🤖</div>
          <div style="flex:1; min-width:0; background:white; border:1px solid #e5e7eb; border-radius:4px 18px 18px 18px; padding:14px 18px; font-size:14px; line-height:1.8; white-space:pre-wrap; word-break:break-word; box-shadow:0 1px 4px rgba(0,0,0,0.06);">
            ${this.escape(text)}
          </div>
        </div>`
    } else {
      wrap.innerHTML = `
        <div style="display:flex; justify-content:center;">
          <div style="background:#fef2f2; color:#dc2626; border:1px solid #fecaca; border-radius:12px; padding:10px 18px; font-size:13px;">
            ${this.escape(text)}
          </div>
        </div>`
    }

    this.messagesTarget.appendChild(wrap)
  }

  removeEmptyState() {
    const el = document.getElementById("ai-chat-empty-state")
    if (el) el.remove()
  }

  setLoading(loading) {
    this.submitTarget.disabled       = loading
    this.loadingTarget.style.display = loading ? "block" : "none"
  }

  scrollBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  escape(text) {
    return text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/\n/g, "<br>")
  }
}
