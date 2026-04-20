class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string  :title,       null: false
      t.string  :author
      t.string  :status,      null: false, default: "want_to_read"
      t.integer :rating
      t.text    :memo
      t.date    :started_on
      t.date    :finished_on
      t.timestamps
    end
  end
end
