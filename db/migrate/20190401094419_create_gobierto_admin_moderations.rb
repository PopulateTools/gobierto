# frozen_string_literal: true

class CreateGobiertoAdminModerations < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_moderations do |t|
      t.references :site
      t.references :moderable, polymorphic: true
      t.references :admin
      t.integer :stage, null: false, default: 0

      t.timestamps
    end
  end
end
