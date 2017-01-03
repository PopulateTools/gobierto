module GobiertoCommon
  module DynamicContent
    extend ActiveSupport::Concern

    included do
      has_many :content_block_records, as: :content_context, dependent: :destroy, class_name: "GobiertoCommon::ContentBlockRecord"

      def self.content_blocks(site_id)
        GobiertoCommon::ContentBlock.where(site_id: site_id, content_model_name: model_name.name)
      end

      def content_blocks(site_id)
        GobiertoCommon::ContentBlock.where(site_id: site_id, content_model_name: model_name.name)
      end
    end
  end
end
