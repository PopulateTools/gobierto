# frozen_string_literal: true

class CreateUserApiTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :user_api_tokens do |t|
      t.references :user
      t.string :name
      t.string :token
      t.boolean :primary, default: false

      t.timestamps
    end

    User.all.each(&:primary_api_token!)
  end
end
