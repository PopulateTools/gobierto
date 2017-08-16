# frozen_string_literal: true

class AddGenderToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :gender, :integer
  end
end
