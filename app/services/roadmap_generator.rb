require "net/http"
require "json"
require "uri"

class RoadmapGenerator
  OLLAMA_API_URL = "http://host.docker.internal:11434/v1/chat/completions"
  OLLAMA_MODEL   = "llama3.2"

  def initialize(profile, roadmap)
    @profile = profile
    @roadmap = roadmap
  end

  def generate
    uri = URI(OLLAMA_API_URL)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = false
    http.read_timeout = 180

    request                 = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body            = request_body.to_json

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error "Ollama API error: #{response.code} #{response.body}"
      return nil
    end

    data = JSON.parse(response.body)
    text = data.dig("choices", 0, "message", "content")
    return nil unless text

    parse_response(text)
  rescue => e
    Rails.logger.error "RoadmapGenerator error: #{e.class}: #{e.message}"
    nil
  end

  private

  def auto_duration_mode?
    @roadmap.duration_days.blank?
  end

  def request_body
    {
      model:       OLLAMA_MODEL,
      max_tokens:  12000,
      temperature: 0.3,
      messages: [
        { role: "system", content: system_prompt },
        { role: "user",   content: user_prompt }
      ]
    }
  end

  def system_prompt
    json_format = if auto_duration_mode?
      <<~JSON
        {
          "title": "ロードマップのタイトル（30文字以内）",
          "duration_days": 30,
          "tasks": [
            {
              "day": 1,
              "title": "タスクのタイトル（40文字以内）",
              "description": "具体的な学習内容（200文字程度）"
            }
          ]
        }
      JSON
    else
      <<~JSON
        {
          "title": "ロードマップのタイトル（30文字以内）",
          "tasks": [
            {
              "day": 1,
              "title": "タスクのタイトル（40文字以内）",
              "description": "具体的な学習内容（200文字程度）"
            }
          ]
        }
      JSON
    end

    <<~PROMPT
      あなたは学習計画の専門家です。ユーザーが指定した「勉強内容」だけに集中したロードマップを作成します。

      【厳守ルール】
      - 指定された勉強内容以外のトピックは絶対に含めないこと
      - 過去の会話や他のロードマップの内容は一切参照しないこと
      - 今回のリクエストだけを見て、ゼロから計画を作ること

      descriptionには以下を必ず含めること：
      - その日に具体的に何をするか（教材名・ツール名・章番号など）
      - どのくらいの時間をかけるか
      - 何ができるようになるか・何を理解するか
      - 具体的な練習内容や成果物

      出力は必ず以下のJSON形式のみで行い、コードブロックや説明文は一切含めないこと：
      #{json_format}
    PROMPT
  end

  def user_prompt
    hours_info = @roadmap.daily_hours.present? ? "1日の勉強時間: #{@roadmap.daily_hours}時間" : nil
    duration_info = auto_duration_mode? ? nil : "勉強期間: #{@roadmap.duration_days}日間"

    <<~PROMPT
      以下の情報でロードマップを作成してください。

      【学習者のプロフィール】
      スキル・経験: #{@profile.skills.presence || "未記入"}
      保有資格・実績: #{@profile.certifications.presence || "未記入"}

      【学習計画】
      勉強内容: #{@roadmap.study_content}
      詳細な目的: #{@roadmap.purpose}
      #{[ hours_info, duration_info ].compact.join("\n      ")}

      #{task_granularity_instruction}

      各タスクのdescriptionは必ず200文字程度で、具体的な教材・ツール・手順・目標を含めること。「〇〇を学ぶ」のような抽象的な記述は禁止。
    PROMPT
  end

  def task_granularity_instruction
    if auto_duration_mode?
      <<~INST
        勉強内容・目的・1日の勉強時間をもとに、習得に必要な適切な日数を決定してください。
        決定した日数をduration_daysに設定し、以下のルールでタスクを作成してください：
        - 30日以内 → 一日ごとにタスクを作成。dayは1から始まる整数
        - 31〜90日 → 週ごとにタスクを作成。dayは1, 8, 15...のように週の開始日
        - 91日以上 → 月ごとにタスクを作成。dayは1, 31, 61...のように月の開始日
      INST
    else
      days = @roadmap.duration_days
      if days <= 30
        "一日ごとにタスクを#{days}個作成してください。dayは1から#{days}の整数。"
      elsif days <= 90
        weeks = (days / 7.0).ceil
        "週ごとにタスクを#{weeks}個作成してください。dayは1, 8, 15...のように週の開始日。"
      else
        months = (days / 30.0).ceil
        "月ごとにタスクを#{months}個作成してください。dayは1, 31, 61...のように月の開始日。"
      end
    end
  end

  def parse_response(text)
    cleaned = text.gsub(/```json\n?/, "").gsub(/```\n?/, "").strip
    data    = JSON.parse(cleaned)
    { title: data["title"], duration_days: data["duration_days"], tasks: data["tasks"] }
  rescue JSON::ParserError => e
    Rails.logger.error "JSON parse error: #{e.message}\nRaw: #{text}"
    nil
  end
end
