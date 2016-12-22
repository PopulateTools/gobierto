class AddSeenFlagToUserNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :user_notifications, :is_seen, :boolean, null: false, default: false
    add_index :user_notifications, :is_seen
  end
end
