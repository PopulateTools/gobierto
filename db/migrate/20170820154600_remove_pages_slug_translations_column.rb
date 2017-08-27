# frozen_string_literal: true

class RemovePagesSlugTranslationsColumn < ActiveRecord::Migration[5.1]
  def change
    remove_column :gcms_pages, :slug_translations
  end
end
