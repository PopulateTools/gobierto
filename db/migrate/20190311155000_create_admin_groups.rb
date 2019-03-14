# frozen_string_literal: true

class CreateAdminGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_admin_groups do |t|
      t.references :site, index: true
      t.string :name
    end
  end
end
