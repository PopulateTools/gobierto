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
        attachments_collection = GobiertoCommon::Collection.find_by(container: attachable.collection.container,
                                                                    item_type: "GobiertoAttachments::Attachment")

        unless attachments_collection
          attachments_collection = site.collections.create container: attachable.collection.container,
                                                           item_type: "GobiertoAttachments::Attachment",
                                                           slug: "attachment-#{attachable.collection.slug}",
                                                           title: I18n.t("gobierto_participation.shared.documents")
        end
        attachment.update(collection: attachments_collection)

        attachments_collection.append(attachment)
      end
    end
  end
end
