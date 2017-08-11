# frozen_string_literal: true

class AddLastSignInFieldsToAdmins < ActiveRecord::Migration[5.0]
  def change
    add_column :admins, :last_sign_in_at, :datetime
    add_column :admins, :last_sign_in_ip, :inet
  end
end
