class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :roadmap, null: false, foreign_key: true
      t.integer :day_number, null: false
      t.string :title, null: false
      t.text :description
      t.boolean :completed, null: false, default: false
      t.datetime :completed_at

      t.timestamps
    end

    add_index :tasks, [:roadmap_id, :day_number]
  end
end
