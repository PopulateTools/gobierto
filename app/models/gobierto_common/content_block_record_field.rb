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
  end
end
