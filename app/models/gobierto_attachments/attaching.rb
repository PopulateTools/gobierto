require_dependency 'gobierto_attachments'

module GobiertoAttachments
  class Attaching < ApplicationRecord

    belongs_to :site
    belongs_to :attachment
    belongs_to :attachable, polymorphic: true

    validates :site, :attachment, presence: true

    before_validation :set_site

    private

    def set_site
      self.site ||= attachment.try(:site) || attachable.try(:site)
    end

  end
end
