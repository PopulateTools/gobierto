# frozen_string_literal: true

class AddSitesTranslations < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :name_translations, :jsonb
    add_column :sites, :title_translations, :jsonb

    add_index :sites, :name_translations, using: :gin
    add_index :sites, :title_translations, using: :gin
  end
end
