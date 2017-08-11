# frozen_string_literal: true

class GobiertoCommonUpdateTitleTranslations < ActiveRecord::Migration[5.1]
  def change
    Site.all.each do |site|
      site.collections.each do |collection|
        collection.title_translations = { "ca": "Lloc", "en": "Site", "es": "Sitio" }
        collection.save
      end
    end
  end
end
