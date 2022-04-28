# frozen_string_literal: true

module GobiertoCommon
  module HasCustomFieldsAttributes

    extend ActiveSupport::Concern

    def attributes(*args)
      data = super

      if data[:id].present?
        if has_preloaded_data?
          data.merge!(preloaded_data[data[:id]]) if preloaded_data.has_key?(data[:id])
        else
          ::GobiertoCommon::CustomFieldRecord.includes(:custom_field).where(custom_field: custom_fields, item: object).sorted.each do |record|
            uid = record.custom_field.uid
            record = record.versions[@version_index]&.reify if @version_index&.negative?

            data[uid] = record&.send(value_method)
          end
        end
      else
        custom_fields.each do |custom_field|
          data[custom_field.uid] = custom_field.records.new.send(value_method)
        end
      end

      data
    end

    included do
      attribute :searchable_custom_fields, if: :serialize_for_search_engine?
    end

    def searchable_custom_fields
      ::GobiertoCommon::CustomFieldRecord.includes(:custom_field).where(custom_field: custom_fields, item: object).map do |record|
        record = record.versions[@version_index]&.reify if @version_index&.negative?
        record&.searchable_value
      end.join(" ")
    end

    def custom_fields
      @custom_fields ||= current_site.custom_fields.for_class(object.class).sorted
    end

    def has_preloaded_data?
      @has_preloaded_data ||= instance_options.has_key?(:preloaded_data)
    end

    def preloaded_data
      @preloaded_data ||= instance_options[:preloaded_data]
    end

    def value_method
      @value_method ||= instance_options.fetch(:custom_fields_value_method, instance_options[:string_output] ? :value_string : :value)
    end

    def serialize_for_search_engine?
      @serialize_for_search_engine ||= instance_options[:serialize_for_search_engine]
    end

    def cache_key(arg)
      super

      @cache_key = [@cache_key, I18n.locale].join("/")
    end
  end
end
