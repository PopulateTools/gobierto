# frozen_string_literal: true

class CreateGobiertoCmsSectionModels < ActiveRecord::Migration[5.1]
  def change
    create_table :gcms_sections do |t|
      t.jsonb :title_translations
      t.string :slug, null: false, default: ""
      t.references :site

      t.timestamps
    end

    create_table :gcms_section_items do |t|
      t.belongs_to :item, polymorphic: true
      t.integer :position, null: false, default: 0
      t.integer :parent_id, null: false
      t.references :section
      t.integer :level, null: false, default: 0

      t.timestamps
    end
  end
end
