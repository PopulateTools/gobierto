# frozen_string_literal: true

class AddGcmsPagesTranslations < ActiveRecord::Migration[5.0]
  def change
    remove_index :gcms_pages, name: "index_gcms_pages_on_slug_and_site_id", unique: true

    add_column :gcms_pages, :title_translations, :jsonb
    add_column :gcms_pages, :body_translations, :jsonb
    add_column :gcms_pages, :slug_translations, :jsonb

    add_index :gcms_pages, :title_translations, using: :gin
    add_index :gcms_pages, :body_translations, using: :gin
    add_index :gcms_pages, :slug_translations, using: :gin
  end
end
