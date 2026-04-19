class MonthlyExpense < ApplicationRecord
  belongs_to :monthly_budget

  validates :name, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
end
