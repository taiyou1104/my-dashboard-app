require "net/http"
require "json"
require "uri"

class ValorantStrategyService
  OLLAMA_API_URL = "http://host.docker.internal:11434/v1/chat/completions"
  OLLAMA_MODEL   = "llama3.2"

  def initialize(map, agents)
    @map    = map
    @agents = agents
  end

  def call
    uri  = URI(OLLAMA_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = false
    http.read_timeout = 180

    request                 = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body            = request_body.to_json

    response = http.request(request)
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error "ValorantStrategyService error: #{response.code}"
      return nil
    end

    content = JSON.parse(response.body).dig("choices", 0, "message", "content")
    parse_rounds(content)
  rescue => e
    Rails.logger.error "ValorantStrategyService: #{e.class}: #{e.message}"
    nil
  end

  private

  def request_body
    {
      model:       OLLAMA_MODEL,
      max_tokens:  8192,
      temperature: 0.8,
      messages: [
        { role: "system", content: system_prompt },
        { role: "user",   content: user_prompt }
      ]
    }
  end

  def system_prompt
    <<~PROMPT
      あなたはVALORANTのプロコーチです。必ず日本語で、有効なJSONのみを出力してください。説明文・マークダウン・省略記号（...）は一切禁止です。

      出力形式（attackとdefenseそれぞれ必ず12個、省略なし）:
      {"attack":[{"round":1,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":2,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":3,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":4,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":5,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":6,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":7,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":8,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":9,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":10,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":11,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":12,"title":"日本語の作戦名","desc":"日本語の説明"}],"defense":[{"round":1,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":2,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":3,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":4,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":5,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":6,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":7,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":8,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":9,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":10,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":11,"title":"日本語の作戦名","desc":"日本語の説明"},{"round":12,"title":"日本語の作戦名","desc":"日本語の説明"}]}

      ルール:
      - title・descすべて日本語で書く
      - descは3〜5文で詳細に記述すること。以下を必ず含める：
        ① 各エージェントの具体的なポジションと役割
        ② 使用するアビリティ名と使用タイミング
        ③ 攻め先・守りポジションの具体的なマップ上の場所（例：Aメイン、Bショート、ミッドリンクなど）
        ④ 経済状況（エコ／フォースバイ／フルバイ）の明示
        ⑤ フェイクや情報操作がある場合はその手順
      - エコ・フォースバイ・デフォルト・速攻・フェイクなど多様な戦術を混ぜる
      - 「...」や「[...]」による省略は絶対禁止。12ラウンドすべてを必ず書ききること
    PROMPT
  end

  def user_prompt
    "マップ: #{@map}\nエージェント構成: #{@agents}\n\n攻撃12ラウンド・防衛12ラウンドの作戦をすべて日本語で生成してください。"
  end

  def parse_rounds(content)
    return nil if content.blank?

    json_str = content.gsub(/```json\s*|\s*```/, "").strip
    if (m = json_str.match(/\{[\s\S]*\}/))
      json_str = m[0]
    end

    data    = JSON.parse(json_str)
    attack  = (data["attack"]  || []).first(12)
    defense = (data["defense"] || []).first(12)

    { attack: attack, defense: defense }
  rescue JSON::ParserError => e
    Rails.logger.error "ValorantStrategyService parse error: #{e.message}\nContent: #{content}"
    nil
  end
end
