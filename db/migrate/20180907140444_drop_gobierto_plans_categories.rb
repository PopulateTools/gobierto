# frozen_string_literal: true

class DropGobiertoPlansCategories < ActiveRecord::Migration[5.2]
  def up
    drop_table :gplan_categories
  end

  def down
    create_table :gplan_categories do |t|
      t.jsonb :name_translations
      t.integer :level, default: 0, null: false
      t.integer :parent_id
      t.references :plan
      t.string :slug, null: false, default: ""
      t.float "progress"
      t.string "uid"
      t.timestamps
    end
  end
end
