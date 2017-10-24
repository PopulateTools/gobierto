# frozen_string_literal: true

class AttachmentsCreateSlugs < ActiveRecord::Migration[5.1]
  def self.up
    GobiertoAttachments::Attachment.all.each do |attachment|
      attachment.update_column :slug, attachment.attributes_for_slug.join('-').gsub('_', ' ').parameterize
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
