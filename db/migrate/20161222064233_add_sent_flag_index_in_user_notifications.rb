class AddSentFlagIndexInUserNotifications < ActiveRecord::Migration[5.0]
  def change
    add_index :user_notifications, :is_sent
  end
end
