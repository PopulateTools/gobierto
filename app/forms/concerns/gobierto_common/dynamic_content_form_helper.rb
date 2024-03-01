# frozen_string_literal: true

module GobiertoCommon
  module DynamicContentFormHelper
    attr_accessor :content_block_records_attributes

    class BadInitialization < StandardError; end

    def initialize(options = {})
      content_block_records_attributes_param = options[:content_block_records_attributes]
      if content_block_records_attributes_param
        options.delete(:content_block_records_attributes)
        options[:content_block_records_attributes] = content_block_records_attributes_param
      end
      super(options)
    end

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
        next if content_block_record_attributes["_destroy"] == "1"

        content_block_record_params = {
          content_block_id: content_block_record_attributes[:content_block_id],
          fields_attributes: content_block_record_attributes[:fields_attributes],
          attachment_url: get_attachment_url(content_block_record_attributes)
        }

        content_block_record = GobiertoCommon::ContentBlockRecord.new(content_block_record_params)

        if content_block_record.payload.present?
          @content_block_records.push(content_block_record)
        end
      end
    end

    private

    def get_attachment_url(content_block_record_attributes)
      if content_block_record_attributes[:remove_attachment] == "1"
        nil
      else
        attachment_file = content_block_record_attributes[:attachment_file]

        if attachment_file
          upload_content_block_record_attachment_file(attachment_file)
        else
          existing_content_block_record = ContentBlockRecord.find_by(id: content_block_record_attributes[:id])
          existing_content_block_record.try(:attachment_url)
        end
      end
    end

    def upload_content_block_record_attachment_file(attachment_file)
      raise(BadInitialization, "Site is not yet set or initialized") if site.nil?

      FileUploadService.new(
        site: site,
        collection: person.model_name.collection,
        attribute_name: :attachment,
        file: attachment_file
      ).upload!
    end

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
