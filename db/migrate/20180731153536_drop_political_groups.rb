# frozen_string_literal: true

class DropPoliticalGroups < ActiveRecord::Migration[5.2]
  def up
    drop_table :gp_political_groups
  end

  def down
    create_table :gp_political_groups do |t|
      t.references :site
      t.references :admin
      t.string :name, null: false, default: ""
      t.integer :position, default: 0, null: false
      t.string :slug, default: "", null: false

      t.timestamps
    end
  end
end
