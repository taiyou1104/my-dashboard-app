class Task < ApplicationRecord
  belongs_to :roadmap

  validates :day_number, :title, presence: true

  scope :ordered, -> { order(:day_number) }
end
