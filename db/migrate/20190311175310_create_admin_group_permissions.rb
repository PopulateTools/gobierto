# frozen_string_literal: true

class CreateAdminGroupPermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_group_permissions do |t|
      t.references :admin_group, index: true
      t.string :namespace, null: false, default: ""
      t.string :resource_name, null: false, default: ""
      t.bigint :resource_id
      t.string :action_name, null: false, default: ""
    end

    add_index :admin_group_permissions, [:admin_group_id, :namespace, :resource_name, :resource_id, :action_name], name: "index_admin_permissions_on_admin_group_id_and_fields"
  end
end
