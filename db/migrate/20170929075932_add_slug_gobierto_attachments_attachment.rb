# frozen_string_literal: true

class AddSlugGobiertoAttachmentsAttachment < ActiveRecord::Migration[5.1]
  def change
    add_column :ga_attachments, :slug, :string, null: false, default: ""
  end
end
