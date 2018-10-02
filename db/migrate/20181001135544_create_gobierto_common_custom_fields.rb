# frozen_string_literal: true

class CreateGobiertoCommonCustomFields < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_fields do |t|
      t.references :site
      t.string :class_name
      t.integer :position, null: false, default: 0
      t.jsonb :name_translations
      t.boolean :mandatory, default: false
      t.integer :field_type, null: false, default: 0
      t.jsonb :options
      t.string :uid, default: "", null: false

      t.timestamps
    end

    add_index :custom_fields, [:site_id, :uid, :class_name], unique: true
  end
end
