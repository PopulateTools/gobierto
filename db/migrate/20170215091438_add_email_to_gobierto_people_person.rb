class AddEmailToGobiertoPeoplePerson < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_people, :email, :string
  end
end
