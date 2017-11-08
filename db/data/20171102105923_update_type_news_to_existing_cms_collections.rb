# frozen_string_literal: true

class UpdateTypeNewsToExistingCmsCollections < ActiveRecord::Migration[5.1]
  def up
    GobiertoCommon::Collection.where(item_type: "GobiertoCms::Page", container_type: "GobiertoParticipation::Process").update_all(item_type: "GobiertoCms::News")
    Site.all.each do |s|
      s.collections.where(item_type: "GobiertoCms::News").each do |c|
        c.collection_items.where(item_type: "GobiertoCms::Page").each do |i|
          i.item_type = "GobiertoCms::News"
          i.save!
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
