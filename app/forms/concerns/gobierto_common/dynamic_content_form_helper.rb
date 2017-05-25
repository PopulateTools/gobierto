# frozen_string_literal: true

module GobiertoCommon
  module DynamicContentFormHelper
    attr_accessor :content_block_records_attributes

    def content_block_records
      @content_block_records ||= content_context.content_block_records.sorted
    end

    def content_blocks
      @content_blocks ||= begin
        content_context.content_blocks(site_id).includes(:fields).map do |content_block|
          OpenStruct.new(
            id: content_block.id,
            title: content_block.title[I18n.locale.to_s],
            header: content_block_field_labels_for(content_block),
            records: content_block_records.select do |content_block_record|
              content_block_record.content_block_id == content_block.id
            end.presence || build_content_block_record_for(content_block)
          )
        end
      end
    end

    def content_block_records_attributes=(attributes)
      @content_block_records ||= []

      attributes.each do |_, content_block_record_attributes|
        next if content_block_record_attributes['_destroy'] == '1'

        content_block_record = GobiertoCommon::ContentBlockRecord.new(
          content_block_id: content_block_record_attributes[:content_block_id],
          fields_attributes: content_block_record_attributes[:fields_attributes]
        )

        if content_block_record.payload.present?
          @content_block_records.push(content_block_record)
        end
      end
    end

    private

    def build_content_block_record_for(content_block)
      GobiertoCommon::ContentBlockRecord.new(content_block: content_block)
    end

    def content_block_field_labels_for(content_block)
      content_block.fields.sorted.pluck(:label).map do |label|
        label[I18n.locale.to_s]
      end
    end
  end
end
