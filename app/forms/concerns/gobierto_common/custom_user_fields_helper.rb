# frozen_string_literal: true

module GobiertoCommon
  module CustomUserFieldsHelper
    extend ActiveSupport::Concern

    included do
      validate :valid_custom_records
    end

    def custom_records
      @custom_records ||= if user.nil?
                            site.presence ? site.custom_user_fields.map { |custom_user_field| custom_user_field.records.new } : []
                          elsif user.custom_records.empty?
                            site.presence ? site.custom_user_fields.map { |custom_user_field| user.custom_records.build(custom_user_field: custom_user_field) } : []
                          else
                            user.custom_records
                          end
    end

    def custom_records=(attributes)
      @custom_records ||= Array(attributes).map do |_, field_attributes|
        custom_record = user.custom_records.find_by(custom_user_field_id: field_attributes["custom_user_field_id"]) || user.custom_records.build(custom_user_field_id: field_attributes["custom_user_field_id"])
        custom_record.value = field_attributes["value"]
        custom_record
      end
    end

    private

    def valid_custom_records
      return if custom_records.empty?

      custom_records.each do |custom_record|
        if custom_record.custom_user_field.mandatory? && custom_record.value.blank?
          errors[:base] << "#{custom_record.custom_user_field.localized_title} #{I18n.t("errors.messages.blank")}"
        end
      end
    end
  end
end
