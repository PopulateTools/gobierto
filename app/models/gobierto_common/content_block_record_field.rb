# frozen_string_literal: true

module GobiertoCommon
  class ContentBlockRecordField
    include ActiveModel::Model

    attr_accessor(
      :content_block_id,
      :name,
      :value,
      :label,
      :field_type
    )

    def url?
      field_type == "url"
    end

  end
end
