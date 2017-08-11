# frozen_string_literal: true

class AttachmentNameCanBeNull < ActiveRecord::Migration[5.1]
  def change
    change_column :ga_attachments, :name, :string, null: true
  end
end
