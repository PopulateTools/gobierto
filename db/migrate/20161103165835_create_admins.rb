# frozen_string_literal: true

class CreateAdmins < ActiveRecord::Migration[5.0]
  def change
    create_table :admins do |t|
      t.string :email, null: false, defaut: ''
      t.string :name, null: false, default: ''
      t.string :password_digest, null: false, default: ''
      t.string :confirmation_token
      t.string :reset_password_token
      t.integer :authorization_level, null: false, default: 0

      t.timestamps
    end

    add_index :admins, :email,                unique: true
    add_index :admins, :reset_password_token, unique: true
    add_index :admins, :confirmation_token,   unique: true
  end
end
