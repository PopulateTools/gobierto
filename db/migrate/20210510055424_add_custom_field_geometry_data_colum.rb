class AddCustomFieldGeometryDataColum < ActiveRecord::Migration[6.0]
  def up
    Site.find_each do |site|
      GobiertoSeeds::GobiertoData::Recipe.run(site) if site.configuration.gobierto_data_enabled?
    end
  end
  def down
  end
end
