module GobiertoCommon
  module DynamicContent
    extend ActiveSupport::Concern

    CONTACT_BLOCK_ID = "gobierto_people_contact_block"
    CUSTOM_LINKS_BLOCK_ID = "gobierto_people_custom_links"

    included do
      has_many :content_block_records, as: :content_context, dependent: :destroy, class_name: "GobiertoCommon::ContentBlockRecord"

      def self.content_blocks(site_id)
        GobiertoCommon::ContentBlock
          .set_content_context(nil)
          .includes(:fields)
          .where(site_id: site_id, content_model_name: model_name.name)
      end

      def content_blocks(site_id = self[:site_id])
        GobiertoCommon::ContentBlock
          .set_content_context(self)
          .includes(:fields)
          .where(site_id: site_id, content_model_name: model_name.name)
      end
    end
  end
end
