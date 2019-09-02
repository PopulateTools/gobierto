# frozen_string_literal: true

class AddApiTokenToAdmins < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_admins, :api_token, :string, null: true
  end
end
