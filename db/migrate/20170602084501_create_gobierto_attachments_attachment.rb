# frozen_string_literal: true

class CreateGobiertoAttachmentsAttachment < ActiveRecord::Migration[5.1]
  def change
    create_table :ga_attachments do |t|
      t.integer :site_id, null: false
      t.string :name, null: false
      t.text :description
      t.string :file_name, null: false
      t.string :file_digest, null: false
      t.string :url, null: false
      t.integer :file_size, null: false
      t.integer :current_version, null: false, default: 0
    end
  end
end
