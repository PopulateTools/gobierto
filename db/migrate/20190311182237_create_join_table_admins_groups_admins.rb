# frozen_string_literal: true

class CreateJoinTableAdminsGroupsAdmins < ActiveRecord::Migration[5.2]
  def change
    create_join_table :admins, :admin_groups
  end
end
