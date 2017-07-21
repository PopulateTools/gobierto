class GobiertoCommonUpdateTitleTranslations < ActiveRecord::Migration[5.1]
  def change
    Site.all.each do |site|
      collection = GobiertoCommon::Collection.first
      collection.title_translations = {"ca": "Lloc", "en": "Site", "es": "Sitio"}
      collection.save
    end
  end
end
