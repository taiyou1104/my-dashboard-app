class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.text :skills
      t.text :certifications

      t.timestamps
    end
  end
end
