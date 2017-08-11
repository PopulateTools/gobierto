# frozen_string_literal: true

class AddCensusVerifiedFieldToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :census_verified, :boolean, null: false, default: false
  end
end
