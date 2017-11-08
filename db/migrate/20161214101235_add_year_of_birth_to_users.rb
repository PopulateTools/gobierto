# frozen_string_literal: true

class AddYearOfBirthToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :year_of_birth, :integer
  end
end
