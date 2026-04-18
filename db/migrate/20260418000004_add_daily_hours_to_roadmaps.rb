class AddDailyHoursToRoadmaps < ActiveRecord::Migration[8.1]
  def change
    add_column :roadmaps, :daily_hours, :decimal, precision: 3, scale: 1
    change_column_null :roadmaps, :duration_days, true
  end
end
