# frozen_string_literal: true

class AddGroupTypeColumnToAdminAdminGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_admin_groups, :group_type, :integer, null: false, default: 0
  end
end
