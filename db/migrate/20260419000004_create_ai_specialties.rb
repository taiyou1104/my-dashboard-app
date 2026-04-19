class CreateAiSpecialties < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_specialties do |t|
      t.string  :name,             null: false
      t.string  :description,      null: false
      t.string  :icon_emoji,       null: false, default: "🤖"
      t.string  :color,            null: false, default: "#6366f1"
      t.string  :bg_color,         null: false, default: "#eef2ff"
      t.string  :input_placeholder, null: false, default: "キーワードや概要を入力..."
      t.text    :system_prompt,    null: false
      t.text    :prompt_template,  null: false
      t.integer :position,         null: false, default: 0
      t.timestamps
    end
  end
end
