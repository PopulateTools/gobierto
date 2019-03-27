# frozen_string_literal: true

module GobiertoCommon
  module DynamicContentHelper
    extend ActiveSupport::Concern

    private

    def dynamic_content_attributes
      {
        content_block_records_attributes: [
          :id,
          :content_block_id,
          :_destroy,
          fields_attributes: [:name, :value]
        ]
      }
    end
  end
end
