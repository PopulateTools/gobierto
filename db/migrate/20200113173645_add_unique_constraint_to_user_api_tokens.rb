# frozen_string_literal: true

class AddUniqueConstraintToUserApiTokens < ActiveRecord::Migration[5.2]
  def change
    add_index :user_api_tokens, :token, unique: true
  end
end
