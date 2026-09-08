# frozen_string_literal: true

class AddNotificationSettingsToAdmins < ActiveRecord::Migration[6.1]
  def change
    add_column :admin_admins, :notification_settings, :jsonb, null: false, default: {}
  end
end
