# frozen_string_literal: true

module GobiertoCommon
  module HasCustomFieldsAttributes

    extend ActiveSupport::Concern

    def attributes(*args)
      data = super

      if data[:id].present?
        ::GobiertoCommon::CustomFieldRecord.includes(:custom_field).where(custom_field: custom_fields, item: object).sorted.each do |record|
          data[record.custom_field.uid] = instance_options[:string_output] ? record.value_string : record.value
        end
      else
        custom_fields.each do |custom_field|
          data[custom_field.uid] = instance_options[:string_output] ? custom_field.records.new.value_string : custom_field.records.new.value
        end
      end

      data
    end

    def custom_fields
      @custom_fields ||= current_site.custom_fields.where(class_name: object.class.name).sorted
    end

  end
end
