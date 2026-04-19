require "net/http"
require "json"
require "base64"

class ReceiptScanner
  API_URL = "https://api.anthropic.com/v1/messages"
  MODEL   = "claude-haiku-4-5-20251001"

  def initialize(image_data, media_type)
    @image_data = image_data
    @media_type = media_type
  end

  def call
    uri  = URI(API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl     = true
    http.read_timeout = 30

    req = Net::HTTP::Post.new(uri)
    req["Content-Type"]      = "application/json"
    req["x-api-key"]         = ENV["ANTHROPIC_API_KEY"]
    req["anthropic-version"] = "2023-06-01"
    req.body = build_payload.to_json

    res  = http.request(req)
    data = JSON.parse(res.body)
    text = data.dig("content", 0, "text")
    parse(text)
  rescue => e
    Rails.logger.error("ReceiptScanner error: #{e}")
    nil
  end

  private

  def build_payload
    {
      model: MODEL,
      max_tokens: 1024,
      messages: [
        {
          role: "user",
          content: [
            {
              type: "image",
              source: { type: "base64", media_type: @media_type, data: @image_data }
            },
            {
              type: "text",
              text: <<~PROMPT
                このレシート画像から購入した商品・サービスの名前と金額を全て抽出してください。
                合計金額・小計・税額・ポイントは含めないでください。
                商品名は簡潔にしてください（最大20文字）。
                必ず以下のJSON配列のみを返してください（説明文不要）:
                [{"name":"商品名","amount":金額(整数)}]
              PROMPT
            }
          ]
        }
      ]
    }
  end

  def parse(text)
    return nil if text.blank?
    cleaned = text.gsub(/```json\n?/, "").gsub(/```\n?/, "").strip
    items = JSON.parse(cleaned)
    items.select { |i| i["name"].present? && i["amount"].to_i > 0 }
  rescue
    nil
  end
end
