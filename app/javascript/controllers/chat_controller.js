import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "messages", "input", "sendButton", "taskSelect", "contextLabel"]
  static values  = { chatUrl: String, roadmapTitle: String }

  connect() {
    this.history        = []
    this.selectedTaskId = null
  }

  togglePanel() {
    const panel = this.panelTarget
    if (panel.style.display === "none" || panel.style.display === "") {
      panel.style.display = "flex"
      this.inputTarget.focus()
    } else {
      panel.style.display = "none"
    }
  }

  selectTask(event) {
    this.selectedTaskId = event.target.value || null
    const label = this.selectedTaskId
      ? event.target.options[event.target.selectedIndex].text
      : this.roadmapTitleValue
    this.contextLabelTarget.textContent = label
  }

  handleKey(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.sendMessage()
    }
  }

  async sendMessage() {
    const content = this.inputTarget.value.trim()
    if (!content || this.sendButtonTarget.disabled) return

    this.history.push({ role: "user", content })
    this.appendMessage("user", content)
    this.inputTarget.value = ""
    this.setLoading(true)

    try {
      const response = await fetch(this.chatUrlValue, {
        method:  "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken(),
          "Accept":       "application/json"
        },
        body: JSON.stringify({
          messages: this.history,
          task_id:  this.selectedTaskId
        })
      })

      const data = await response.json()

      if (!response.ok) {
        this.appendMessage("error", data.error || "エラーが発生しました。")
        return
      }

      this.history.push({ role: "assistant", content: data.message })
      this.appendMessage("assistant", data.message)
    } catch (err) {
      console.error("Chat error:", err)
      this.appendMessage("error", "通信エラーが発生しました。もう一度お試しください。")
    } finally {
      this.setLoading(false)
    }
  }

  appendMessage(role, content) {
    const wrapper = document.createElement("div")

    if (role === "user") {
      wrapper.className = "flex justify-end"
      wrapper.innerHTML = `<div style="max-width:80%;background:#4f46e5;color:#fff;border-radius:1rem 1rem 0.25rem 1rem;padding:0.625rem 1rem;font-size:0.875rem;white-space:pre-wrap;">${this.escape(content)}</div>`
    } else if (role === "assistant") {
      wrapper.className = "flex justify-start"
      wrapper.innerHTML = `<div style="max-width:80%;background:#eef2ff;color:#312e81;border-radius:1rem 1rem 1rem 0.25rem;padding:0.625rem 1rem;font-size:0.875rem;white-space:pre-wrap;">${this.escape(content)}</div>`
    } else {
      wrapper.className = "flex justify-center"
      wrapper.innerHTML = `<div style="font-size:0.75rem;color:#ef4444;padding:0.5rem 1rem;">${this.escape(content)}</div>`
    }

    this.messagesTarget.appendChild(wrapper)
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  setLoading(isLoading) {
    this.sendButtonTarget.disabled = isLoading

    if (isLoading) {
      const indicator = document.createElement("div")
      indicator.id        = "chat-typing-indicator"
      indicator.className = "flex justify-start"
      indicator.innerHTML = `<div style="background:#eef2ff;color:#818cf8;border-radius:1rem 1rem 1rem 0.25rem;padding:0.625rem 1rem;font-size:0.875rem;">考え中...</div>`
      this.messagesTarget.appendChild(indicator)
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    } else {
      const el = document.getElementById("chat-typing-indicator")
      if (el) el.remove()
    }
  }

  csrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.content : ""
  }

  escape(str) {
    return String(str)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
  }
}
