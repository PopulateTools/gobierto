# frozen_string_literal: true

class UpdateTypeNewsToExistingCmsCollections < ActiveRecord::Migration[5.1]
  def up
    Site.all.each do |site|
      cms_collections = GobiertoCommon::Collection.where(item_type: "GobiertoCms::Page", site: site)
      cms_collections.update_all(item_type: "GobiertoCms::New")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
