class CreateRoadmaps < ActiveRecord::Migration[8.1]
  def change
    create_table :roadmaps do |t|
      t.string :title
      t.text :study_content, null: false
      t.text :purpose, null: false
      t.integer :duration_days, null: false
      t.string :status, null: false, default: "in_progress"

      t.timestamps
    end
  end
end
