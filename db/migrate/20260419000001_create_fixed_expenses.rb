class CreateFixedExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :fixed_expenses do |t|
      t.string :name, null: false
      t.decimal :amount, precision: 10, scale: 0, null: false
      t.timestamps
    end
  end
end
