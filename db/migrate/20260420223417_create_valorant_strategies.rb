class CreateValorantStrategies < ActiveRecord::Migration[8.1]
  def change
    create_table :valorant_strategies do |t|
      t.string :map,     null: false
      t.string :agents,  null: false
      t.text   :attack_rounds
      t.text   :defense_rounds
      t.timestamps
    end
  end
end
