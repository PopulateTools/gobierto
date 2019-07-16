# frozen_string_literal: true

class RenameAdminGroupPermissionsResourceNameColumnToResourceType < ActiveRecord::Migration[5.2]
  def up
    rename_column :admin_group_permissions, :resource_name, :resource_type

    GobiertoAdmin::GroupPermission.where(resource_type: "person").update_all(resource_type: "GobiertoPeople::Person")
  end

  def down
    GobiertoAdmin::GroupPermission.where(resource_type: "GobiertoPeople::Person").update_all(resource_type: "person")

    rename_column :admin_group_permissions, :resource_type, :resource_name
  end
end
