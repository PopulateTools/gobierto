# frozen_string_literal: true

class CreateGobiertoCommonCollection < ActiveRecord::Migration[5.1]
  def change
    create_table :collections do |t|
      t.references :site
      t.jsonb :title_translations
      t.jsonb :slug_translations

      t.timestamps
    end
  end
end
