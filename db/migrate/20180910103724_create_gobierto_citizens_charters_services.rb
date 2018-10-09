# frozen_string_literal: true

class CreateGobiertoCitizensChartersServices < ActiveRecord::Migration[5.2]
  def change
    create_table :gcc_services do |t|
      t.references :site, index: true
      t.jsonb :title_translations
      t.references :category, index: true
      t.string :slug, null: false, default: ""
      t.integer :visibility_level, null: false, default: 0
      t.integer :position, default: 999_999, null: false
      t.datetime :archived_at
      t.index :archived_at

      t.timestamps
    end
  end
end
