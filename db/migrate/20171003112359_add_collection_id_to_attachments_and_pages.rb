# frozen_string_literal: true

class AddCollectionIdToAttachmentsAndPages < ActiveRecord::Migration[5.1]
  def up
    add_column :gcms_pages, :collection_id, :integer
    add_column :ga_attachments, :collection_id, :integer

    page_ids = GobiertoCommon::CollectionItem.where(item_type: "GobiertoCms::Page").pluck(:item_id)
    pages = GobiertoCms::Page.where(id: page_ids)

    pages.all.each do |p|
      collection_item = GobiertoCommon::CollectionItem.where(item: p).first
      if collection_item
        p.collection = collection_item.collection
        p.save!
      end
    end

    attachment_ids = GobiertoCommon::CollectionItem.where(item_type: "GobiertoAttachments::Attachment").pluck(:item_id)
    attachments = GobiertoAttachments::Attachment.where(id: page_ids)

    attachments.all.each do |p|
      collection_item = GobiertoCommon::CollectionItem.where(item: p).first
      if collection_item
        p.collection = collection_item.collection
        p.save!
      end
    end
  end

  def down
    remove_column :gcms_pages, :collection_id
    remove_column :ga_attachments, :collection_id
  end
end
