class RefactorMonthlyBudgetsAddMonthlyExpenses < ActiveRecord::Migration[8.1]
  def change
    remove_column :monthly_budgets, :phone,    :decimal
    remove_column :monthly_budgets, :internet, :decimal

    create_table :monthly_expenses do |t|
      t.references :monthly_budget, null: false, foreign_key: true
      t.string  :name,   null: false
      t.decimal :amount, precision: 10, scale: 0, null: false
      t.timestamps
    end
  end
end
