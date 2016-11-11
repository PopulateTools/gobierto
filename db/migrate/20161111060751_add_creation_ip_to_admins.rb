class AddCreationIpToAdmins < ActiveRecord::Migration[5.0]
  def change
    add_column :admins, :creation_ip, :inet
  end
end
