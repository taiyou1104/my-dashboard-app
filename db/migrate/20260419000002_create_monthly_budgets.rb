class CreateMonthlyBudgets < ActiveRecord::Migration[8.1]
  def change
    create_table :monthly_budgets do |t|
      t.integer :year, null: false
      t.integer :month, null: false
      t.decimal :electricity, precision: 10, scale: 0
      t.decimal :gas,         precision: 10, scale: 0
      t.decimal :water,       precision: 10, scale: 0
      t.decimal :phone,       precision: 10, scale: 0
      t.decimal :internet,    precision: 10, scale: 0
      t.timestamps
    end
    add_index :monthly_budgets, [:year, :month], unique: true
  end
end
