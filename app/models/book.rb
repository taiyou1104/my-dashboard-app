class Book < ApplicationRecord
  STATUSES = {
    "want_to_read" => "読みたい",
    "reading"      => "読んでいる",
    "finished"     => "読んだ"
  }.freeze

  validates :title,  presence: true
  validates :status, inclusion: { in: STATUSES.keys }
  validates :rating, numericality: { only_integer: true, in: 1..5 }, allow_nil: true

  scope :ordered, -> { order(created_at: :desc) }

  def status_label
    STATUSES[status]
  end
end
