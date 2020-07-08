# frozen_string_literal: true

module GobiertoCommon
  module HasCustomFieldsAttributes

    extend ActiveSupport::Concern

    def attributes(*args)
      data = super

      if data[:id].present?
        ::GobiertoCommon::CustomFieldRecord.includes(:custom_field).where(custom_field: custom_fields, item: object).sorted.each do |record|
          uid = record.custom_field.uid
          record = record.versions[@version_index]&.reify if @version_index&.negative?

          data[uid] = record&.send(value_method)
        end
      else
        custom_fields.each do |custom_field|
          data[custom_field.uid] = custom_field.records.new.send(value_method)
        end
      end

      data
    end

    def custom_fields
      @custom_fields ||= current_site.custom_fields.for_class(object.class).sorted
    end

    def value_method
      @value_method ||= instance_options.fetch(:custom_fields_value_method, instance_options[:string_output] ? :value_string : :value)
    end

  end
end
