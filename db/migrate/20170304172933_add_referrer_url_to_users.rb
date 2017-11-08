# frozen_string_literal: true

class AddReferrerUrlToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :referrer_url, :string
    add_column :users, :referrer_entity, :string
  end
end
