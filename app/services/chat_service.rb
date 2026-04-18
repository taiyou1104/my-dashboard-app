require "net/http"
require "json"
require "uri"

class ChatService
  OLLAMA_API_URL = "http://host.docker.internal:11434/v1/chat/completions"
  OLLAMA_MODEL   = "llama3.2"

  def initialize(roadmap, task, messages)
    @roadmap  = roadmap
    @task     = task
    @messages = messages
  end

  def call
    uri  = URI(OLLAMA_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = false
    http.read_timeout = 60

    request                 = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body            = request_body.to_json

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error "ChatService Ollama error: #{response.code} #{response.body}"
      return nil
    end

    data = JSON.parse(response.body)
    data.dig("choices", 0, "message", "content")
  rescue => e
    Rails.logger.error "ChatService error: #{e.class}: #{e.message}"
    nil
  end

  private

  def request_body
    {
      model:       OLLAMA_MODEL,
      max_tokens:  1024,
      temperature: 0.7,
      messages:    [{ role: "system", content: system_prompt }] + @messages
    }
  end

  def system_prompt
    <<~PROMPT
      あなたは学習サポートアシスタントです。ユーザーが自分で考えて理解できるよう、ソクラテス式の対話で支援します。

      【絶対に守るルール】
      1. 直接的な答えは絶対に教えない
      2. ヒント・誘導質問・参考になる概念・考え方のヒントのみを伝える
      3. 返答は3〜5文以内で簡潔にまとめる
      4. ユーザーが書いた言語（日本語または英語）で返答する
      5. 「答えは〇〇です」「正解は〇〇」のような表現は使わない

      【学習者の現在の学習コンテキスト】
      ロードマップ: #{@roadmap.display_title}
      勉強内容: #{@roadmap.study_content}
      目的: #{@roadmap.purpose}
      #{task_context}
    PROMPT
  end

  def task_context
    return "" unless @task

    <<~TASK

      【現在取り組んでいるタスク】
      Day #{@task.day_number}: #{@task.title}
      #{@task.description}
    TASK
  end
end
