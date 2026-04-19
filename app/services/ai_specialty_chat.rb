require "net/http"
require "json"
require "uri"

class AiSpecialtyChat
  OLLAMA_URL = "http://host.docker.internal:11434/v1/chat/completions"
  MODEL      = "llama3.2"

  def initialize(specialty, messages)
    @specialty = specialty
    @messages  = messages
  end

  def call
    uri  = URI(OLLAMA_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = false
    http.read_timeout = 120

    req                 = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req.body            = {
      model:       MODEL,
      max_tokens:  2048,
      temperature: 0.7,
      messages:    [{ role: "system", content: @specialty.system_prompt }] + @messages
    }.to_json

    res = http.request(req)
    unless res.is_a?(Net::HTTPSuccess)
      Rails.logger.error("AiSpecialtyChat error: #{res.code} #{res.body}")
      return nil
    end

    JSON.parse(res.body).dig("choices", 0, "message", "content")
  rescue => e
    Rails.logger.error("AiSpecialtyChat error: #{e.class}: #{e.message}")
    nil
  end
end
