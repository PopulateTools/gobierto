class AddTimestampToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :created_at, :timestamp, null: false
  end
end
