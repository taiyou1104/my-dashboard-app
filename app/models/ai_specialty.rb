class AiSpecialty < ApplicationRecord
  validates :name, :description, :system_prompt, :prompt_template, presence: true

  scope :ordered, -> { order(:position, :id) }

  def build_first_prompt(user_input)
    prompt_template.gsub("{input}", user_input)
  end
end
