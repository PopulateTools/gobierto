# frozen_string_literal: true

class RenameSentFlagInUserNotifications < ActiveRecord::Migration[5.0]
  def change
    rename_column :user_notifications, :sent, :is_sent
  end
end
