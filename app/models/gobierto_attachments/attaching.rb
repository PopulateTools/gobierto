# frozen_string_literal: true

require_dependency "gobierto_attachments"

module GobiertoAttachments
  class Attaching < ApplicationRecord
    belongs_to :site
    belongs_to :attachment
    belongs_to :attachable, polymorphic: true

    validates :site, :attachment, presence: true

    before_validation :set_site
    after_create :add_item_to_collection

    private

    def set_site
      self.site ||= attachment.try(:site) || attachable.try(:site)
    end

    def add_item_to_collection
      if attachable.collection
        attachable.collection.append(attachment)
      end
    end
  end
end
