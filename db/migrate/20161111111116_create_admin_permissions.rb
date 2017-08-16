# frozen_string_literal: true

class CreateAdminPermissions < ActiveRecord::Migration[5.0]
  def change
    create_table :admin_permissions do |t|
      t.references :admin
      t.string :namespace, null: false, default: ""
      t.string :resource_name, null: false, default: ""
      t.string :action_name, null: false, default: ""
    end

    add_index :admin_permissions, [:admin_id, :namespace, :resource_name, :action_name], name: "index_admin_permissions_on_admin_id_and_fields"
  end
end
