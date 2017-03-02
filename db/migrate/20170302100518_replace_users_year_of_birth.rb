class ReplaceUsersYearOfBirth < ActiveRecord::Migration[5.0]
  def up
    remove_column :users, :year_of_birth
    add_column :users, :date_of_birth, :date
  end

  def down
    remove_column :users, :date_of_birth
    add_column :users, :year_of_birth, integer: true
  end
end
