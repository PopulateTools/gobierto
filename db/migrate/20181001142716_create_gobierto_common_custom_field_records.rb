# frozen_string_literal: true

class CreateGobiertoCommonCustomFieldRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_field_records do |t|
      t.belongs_to :item, polymorphic: true
      t.references :custom_field
      t.jsonb :payload

      t.timestamps
    end

    add_index :custom_field_records, :payload, using: :gin
  end
end
