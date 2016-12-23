class ChangeNameConstraintInUsers < ActiveRecord::Migration[5.0]
  def change
    change_column_null :users, :name, true
    change_column_default :users, :name, from: "", to: nil
  end
end
