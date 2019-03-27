# frozen_string_literal: true

class ChangeUsersEmailIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index :users, :email
    add_index :users, [:email, :site_id], unique: true
  end
end
