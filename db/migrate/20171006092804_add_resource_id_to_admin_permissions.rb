class AddResourceIdToAdminPermissions < ActiveRecord::Migration[5.1]
  
  def change
    add_column :admin_permissions, :resource_id, :bigint
  end

end
