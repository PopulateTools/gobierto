# frozen_string_literal: true

class CreateGdataQueries < ActiveRecord::Migration[5.2]
  def change
    create_table :gdata_queries do |t|
      t.references :dataset, index: true
      t.references :user, index: true
      t.jsonb :name_translations
      t.integer :privacy_status, null: false, default: 0
      t.string :sql
      t.jsonb :options
    end
  end
end
