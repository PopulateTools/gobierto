# frozen_string_literal: true

class ChangePasswordConstraintInUsers < ActiveRecord::Migration[5.0]
  def change
    change_column_null :users, :password_digest, true
    change_column_default :users, :password_digest, from: '', to: nil
  end
end
