# frozen_string_literal: true

module GobiertoCommon
  class ContentBlockRecord < ApplicationRecord
    belongs_to :content_block
    belongs_to :content_context, polymorphic: true

    scope :sorted, -> { order(created_at: :asc) }

    attr_reader(:remove_attachment)

    def fields
      @fields ||= begin
        content_block.fields.sorted.map do |content_block_field|
          ContentBlockRecordField.new(
            content_block_id: content_block_id,
            field_type: content_block_field.field_type,
            name: content_block_field.name,
            value: payload ? payload[content_block_field.name] : "",
            label: content_block_field.label[I18n.locale.to_s]
          )
        end
      end
    end

    def fields=(fields)
      @fields = fields

      self.payload = fields.reduce({}) do |payload_from_fields, field|
        payload_from_fields.merge!({ field.name => field.value })
      end
    end

    def fields_attributes=(attributes)
      payload_from_fields = {}

      Array(attributes).each do |_, field_attributes|
        payload_from_fields.merge!(
          { field_attributes["name"] => field_attributes["value"] }
        )
      end

      if payload_from_fields.values.select(&:present?).any?
        self.payload = payload_from_fields
      end
    end
  end
end
