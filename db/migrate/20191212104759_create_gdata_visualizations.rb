# frozen_string_literal: true

class CreateGdataVisualizations < ActiveRecord::Migration[5.2]
  def change
    create_table :gdata_visualizations do |t|
      t.references :query, index: true
      t.references :user, index: true
      t.jsonb :name_translations
      t.integer :privacy_status, null: false, default: 0
      t.jsonb :spec
    end
  end
end
