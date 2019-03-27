# frozen_string_literal: true

module GobiertoAttachments
  module Attachable
    extend ActiveSupport::Concern

    included do
      has_many :attachings, class_name: "GobiertoAttachments::Attaching", as: :attachable
      has_many :attachments, through: :attachings, class_name: "GobiertoAttachments::Attachment"
    end

    def link_attachment(attachment)
      attachings.create!(site: site, attachment: attachment)
    rescue ActiveRecord::RecordNotUnique
      false
    end

    def unlink_attachment(attachment)
      attachings.find_by!(site: site, attachment: attachment).destroy!
    end

  end
end
