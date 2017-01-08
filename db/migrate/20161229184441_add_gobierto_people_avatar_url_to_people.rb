class AddGobiertoPeopleAvatarUrlToPeople < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_people, :avatar_url, :string
  end
end
