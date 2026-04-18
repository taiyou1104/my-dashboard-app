class Roadmap < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :study_content, :purpose, presence: true
  validates :duration_days, numericality: { greater_than: 0, less_than_or_equal_to: 365 }, allow_nil: true
  validates :daily_hours, numericality: { greater_than: 0, less_than_or_equal_to: 24 }, allow_nil: true
  validate :hours_or_duration_present

  def display_title
    title.presence || study_content.truncate(40)
  end

  def progress_percentage
    return 0 if tasks.empty?
    (tasks.where(completed: true).count.to_f / tasks.count * 100).round
  end

  def completed?
    status == "completed"
  end

  private

  def hours_or_duration_present
    return unless study_content.present?
    if daily_hours.blank? && duration_days.blank?
      errors.add(:base, "1日の勉強時間か勉強期間のどちらかを入力してください")
    end
  end
end
