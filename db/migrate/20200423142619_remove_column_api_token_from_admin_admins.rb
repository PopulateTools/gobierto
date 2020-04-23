# frozen_string_literal: true

class RemoveColumnApiTokenFromAdminAdmins < ActiveRecord::Migration[5.2]
  def change
    remove_column :admin_admins, :api_token, :string, null: true
  end
end
