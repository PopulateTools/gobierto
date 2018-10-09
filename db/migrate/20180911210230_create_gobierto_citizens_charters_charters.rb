# frozen_string_literal: true

class CreateGobiertoCitizensChartersCharters < ActiveRecord::Migration[5.2]
  def change
    create_table :gcc_charters do |t|
      t.references :service, index: true
      t.jsonb :title_translations
      t.string :slug, null: false, default: ""
      t.integer :visibility_level, null: false, default: 0
      t.integer :position, default: 999_999, null: false
      t.datetime :archived_at
      t.index :archived_at

      t.timestamps
    end
  end
end
