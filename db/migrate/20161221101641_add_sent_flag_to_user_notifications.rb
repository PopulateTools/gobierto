# frozen_string_literal: true

class AddSentFlagToUserNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :user_notifications, :sent, :boolean, null: false, default: false
  end
end
