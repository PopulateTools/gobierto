# frozen_string_literal: true

class ChangeCustomFieldsIndex < ActiveRecord::Migration[6.0]
  def up
    remove_index :custom_fields, name: "index_custom_fields_on_site_id_and_uid_and_class_name"
    add_index :custom_fields, [:site_id, :uid, :class_name, :instance_type, :instance_id], name: "index_custom_fields_on_site_class_name_instance_and_uid", unique: true
  end

  def down
    remove_index :custom_fields, name: "index_custom_fields_on_site_class_name_instance_and_uid"
    add_index :custom_fields, [:site_id, :uid, :class_name], unique: true
  end
end
