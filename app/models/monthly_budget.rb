class MonthlyBudget < ApplicationRecord
  UTILITIES = [
    { key: :electricity, label: "電気代" },
    { key: :gas,         label: "ガス代" },
    { key: :water,       label: "水道代" }
  ].freeze

  has_many :monthly_expenses, dependent: :destroy

  validates :year, :month, presence: true
  validates :month, inclusion: { in: 1..12 }
  validates :year, uniqueness: { scope: :month }

  def utility_total
    UTILITIES.map { |u| send(u[:key]) }.compact.sum
  end

  def other_total
    monthly_expenses.sum(:amount)
  end

  def grand_total(fixed_total)
    fixed_total + utility_total + other_total
  end
end
