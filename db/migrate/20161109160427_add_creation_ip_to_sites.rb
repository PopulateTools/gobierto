class AddCreationIpToSites < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :creation_ip, :inet
  end
end
