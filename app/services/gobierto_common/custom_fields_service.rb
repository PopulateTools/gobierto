# frozen_string_literal: true

module GobiertoCommon
  class CustomFieldsService
    attr_reader :site, :relation, :cache_service, :base_cache_key

    include GobiertoHelper

    def initialize(opts = {})
      @relation = opts[:relation]
      @custom_fields = opts[:custom_fields]
      @cache_service = opts[:cache_service]
      @site = opts[:site] || @cache_service&.site
      @base_cache_key = "#{relation.cache_key_with_version}/custom_fields"
    end

    def transformed_custom_field_record_values(reset_cache: false)
      cache_key = "#{base_cache_key}/transformed_values"
      cache_service.delete(cache_key) if reset_cache

      cache_service.fetch(cache_key) do
        calculate_transformed_custom_field_record_values
      end
    end

    def calculate_transformed_custom_field_record_values
        raw_values = custom_field_record_values
        return raw_values if localized_custom_fields.blank? && md_custom_fields.blank?

        localized_uids = localized_custom_fields.pluck(:uid)
        md_uids = md_custom_fields.pluck(:uid)
        raw_values.transform_values do |attributes|
          transform(attributes, localized_uids, :translate)
          transform(attributes, md_uids, :safe_markdown)
          attributes
        end

        raw_values
    end

    private

    def custom_field_record_values
      versions_indexes = relation.respond_to?(:versions_indexes) ? relation.versions_indexes.select { |_, index| index.negative? } : {}

      records_query.group_by(&:item_id).transform_values do |records|
        item_id = records.first&.item_id
        if versions_indexes.has_key?(item_id)
          versioned_payloads(records, versions_indexes[item_id])
        else
          records.pluck(:payload)
        end.inject(:merge)
      end.compact
    end

    def resource
      @resource ||= relation.try(:model)&.new
    end

    def transform(attributes, uids, function)
      uids.each do |uid|
        next unless attributes.present? && attributes[uid].present?

        attributes[uid] = send(function, attributes[uid])
      end
    end

    def records_query
      GobiertoCommon::CustomFieldRecord.where(
        item_condition.merge(custom_field: custom_fields)
      ).sorted.select(:id, :item_id, :payload)
    end

    def item_condition
      if relation.to_sql.include?("custom_field_records")
        { item_type: relation.model.name, item_id: relation.pluck(:id) }
      else
        { item: relation }
      end
    end

    def versioned_payloads(records, version_index)
      records.map do |record|
        version = record.versions[version_index]
        return {} unless version.present? && version.object?

        JSON.parse(version.object_deserialized&.dig("payload") || "{}")
      end
    end

    def translate(hash)
      return hash.to_s unless hash.is_a?(Hash)

      hash = hash.with_indifferent_access
      hash[I18n.locale] || hash[I18n.default_locale] || hash.slice(I18n.available_locales).values&.first || ""
    end

    # This function prevents errors when a md custom field is passed
    # as a Hash because it is localized
    def safe_markdown(value)
      markdown(value.is_a?(Hash) ? translate(value) : value)
    end

    def custom_fields
      @custom_fields ||= if resource.try(:instance_level_custom_fields).present?
                           resource.instance_level_custom_fields
                         else
                           current_site.custom_fields.for_class(resource.class)
                         end
    end

    def localized_custom_fields
      @localized_custom_fields ||= custom_fields.localized
    end

    def md_custom_fields
      @md_custom_fields ||= custom_fields.with_md
    end
  end
end
