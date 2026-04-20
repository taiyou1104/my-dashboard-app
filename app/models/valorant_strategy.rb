class ValorantStrategy < ApplicationRecord
  MAPS = %w[Ascent Bind Haven Split Icebox Breeze Fracture Pearl Lotus Sunset Abyss].freeze

  AGENTS = {
    "デュエリスト" => %w[Jett Raze Reyna Phoenix Yoru Neon Iso],
    "コントローラー" => %w[Omen Brimstone Viper Astra Harbor Clove],
    "イニシエーター" => %w[Sova Breach Skye KAY/O Fade Gekko],
    "センチネル" => %w[Sage Cypher Killjoy Chamber Deadlock Vyse]
  }.freeze

  ALL_AGENTS = AGENTS.values.flatten.freeze

  validates :map,    presence: true, inclusion: { in: MAPS }
  validates :agents, presence: true

  scope :ordered, -> { order(created_at: :desc) }

  def agent_list
    agents.split(",").map(&:strip)
  end

  def parsed_attack_rounds
    JSON.parse(attack_rounds)
  rescue
    []
  end

  def parsed_defense_rounds
    JSON.parse(defense_rounds)
  rescue
    []
  end
end
