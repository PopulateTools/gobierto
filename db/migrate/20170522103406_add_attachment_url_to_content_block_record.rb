# frozen_string_literal: true

class AddAttachmentUrlToContentBlockRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :content_block_records, :attachment_url, :string
  end
end
