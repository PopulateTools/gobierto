class AddGobiertoPeopleClassificationFieldsToPeople < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_people, :category, :integer, null: false, default: 0
    add_column :gp_people, :party, :integer
  end
end
