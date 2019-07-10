# frozen_string_literal: true

class AddTimestampsToAdminGroupsAdmins < ActiveRecord::Migration[5.2]
  def change
    add_timestamps :admin_groups_admins, default: Time.zone.now
    change_column_default :admin_groups_admins, :created_at, nil
    change_column_default :admin_groups_admins, :updated_at, nil
  end
end
