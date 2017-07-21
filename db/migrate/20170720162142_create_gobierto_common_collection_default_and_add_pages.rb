class CreateGobiertoCommonCollectionDefaultAndAddPages < ActiveRecord::Migration[5.1]
  def change
    Site.all.each do |site|
      collection = GobiertoCommon::Collection.create site: site,
                                                     slug: 'site',
                                                     title: 'Sitio',
                                                     container: site,
                                                     item_type: 'GobiertoCms::Page'

      GobiertoCms::Page.all do |page|
        collection.append(page)
      end
    end
  end
end
