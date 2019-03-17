# frozen_string_literal: true

class DropAdminPermissions < ActiveRecord::Migration[5.2]
  def up
    remove_index :admin_permissions, name: "index_admin_permissions_on_admin_id_and_fields"

    drop_table :admin_permissions
  end

  def down
    create_table :admin_permissions do |t|
      t.references :admin
      t.string :namespace, null: false, default: ""
      t.string :resource_name, null: false, default: ""
      t.bigint :resource_id
      t.string :action_name, null: false, default: ""
    end

    add_index :admin_permissions, [:admin_id, :namespace, :resource_name, :action_name], name: "index_admin_permissions_on_admin_id_and_fields"
  end
end
