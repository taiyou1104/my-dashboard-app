# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_18_000004) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "profiles", force: :cascade do |t|
    t.text "certifications"
    t.datetime "created_at", null: false
    t.text "skills"
    t.datetime "updated_at", null: false
  end

  create_table "roadmaps", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "daily_hours", precision: 3, scale: 1
    t.integer "duration_days"
    t.text "purpose", null: false
    t.string "status", default: "in_progress", null: false
    t.text "study_content", null: false
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.boolean "completed", default: false, null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "day_number", null: false
    t.text "description"
    t.bigint "roadmap_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["roadmap_id", "day_number"], name: "index_tasks_on_roadmap_id_and_day_number"
    t.index ["roadmap_id"], name: "index_tasks_on_roadmap_id"
  end

  add_foreign_key "tasks", "roadmaps"
end
