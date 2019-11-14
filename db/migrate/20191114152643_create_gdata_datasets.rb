# frozen_string_literal: true

class CreateGdataDatasets < ActiveRecord::Migration[5.2]
  def change
    create_table :gdata_datasets do |t|
      t.references :site, index: true
      t.jsonb :name_translations
      t.string :table_name
      t.string :slug

      t.timestamps
    end
  end
end
