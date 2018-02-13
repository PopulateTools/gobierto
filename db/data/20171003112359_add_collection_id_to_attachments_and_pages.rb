# frozen_string_literal: true

class AttachmentsCreateSlugs < ActiveRecord::Migration[5.1]
  def self.up
    page_ids = GobiertoCommon::CollectionItem.pages.pluck(:item_id)
    pages = GobiertoCms::Page.where(id: page_ids)

    pages.all.each do |p|
      collection_item = GobiertoCommon::CollectionItem.where(item: p).first
      if collection_item
        p.collection = collection_item.collection
        p.save!
      end
    end

    attachment_ids = GobiertoCommon::CollectionItem.attachments.pluck(:item_id)
    attachments = GobiertoAttachments::Attachment.where(id: page_ids)

    attachments.all.each do |p|
      collection_item = GobiertoCommon::CollectionItem.where(item: p).first
      if collection_item
        p.collection = collection_item.collection
        p.save!
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
