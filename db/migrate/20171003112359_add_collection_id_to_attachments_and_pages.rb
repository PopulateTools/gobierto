# frozen_string_literal: true

class AddCollectionIdToAttachmentsAndPages < ActiveRecord::Migration[5.1]
  def up
    add_column :gcms_pages, :collection_id, :integer
    add_column :ga_attachments, :collection_id, :integer
  end

  def down
    remove_column :gcms_pages, :collection_id
    remove_column :ga_attachments, :collection_id
  end
end
