# frozen_string_literal: true

class CreateGobiertoBudgetsCategory < ActiveRecord::Migration[5.1]
  def change
    create_table :gb_categories do |t|
      t.integer :site_id, null: false
      t.string :area_name, null: false
      t.string :kind, null: false
      t.string :code, null: false
      t.jsonb :custom_name_translations
      t.jsonb :custom_description_translations
    end

    add_index :gb_categories, [:site_id, :area_name, :kind, :code], unique: true, name: "gb_categories_record_unique_index"
  end
end
