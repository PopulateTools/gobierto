class CreateGobiertoCommonCollectionDefaultAndAddPages < ActiveRecord::Migration[5.1]
  def change
    Site.all.each do |site|
      collection = GobiertoCommon::Collection.create! site: site,
                                                      slug: 'site-' + site.name.downcase.delete(' '),
                                                      title_translations: {'es' => 'Sitio' },
                                                      container: site,
                                                      item_type: 'GobiertoCms::Page'

      site.pages.all.each do |page|
        collection.append(page)
      end
    end
  end
end
