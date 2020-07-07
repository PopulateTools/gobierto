# frozen_string_literal: true

module GobiertoCommon
  module CustomFieldsApi
    extend ActiveSupport::Concern
    include GobiertoHelper

    included do
      attr_reader :resource, :vocabularies_adapter

      serialization_scope :current_site
    end

    def filtered_relation
      @resource ||= base_relation.try(:model)&.new
      return base_relation unless filter_params.present?

      query = GobiertoCommon::CustomFieldsQuery.new(relation: base_relation, custom_fields: custom_fields)
      query.filter(filter_params)
    end

    def custom_field_record_values(relation)
      versions_indexes = relation.respond_to?(:versions_indexes) ? relation.versions_indexes.select { |_, index| index.negative? } : {}

      records_query(relation).group_by(&:item_id).transform_values do |records|
        item_id = records.first&.item_id
        if versions_indexes.has_key?(item_id)
          versioned_payloads(records, versions_indexes[item_id])
        else
          records.pluck(:payload)
        end.inject(:merge)
      end.compact
    end

    def transformed_custom_field_record_values(relation)
      raw_values = custom_field_record_values(relation)
      return raw_values if localized_custom_fields.blank? && md_custom_fields.blank?

      localized_uids = localized_custom_fields.pluck(:uid)
      md_uids = md_custom_fields.pluck(:uid)
      raw_values.transform_values do |attributes|
        transform(attributes, localized_uids, :translate)
        transform(attributes, md_uids, :markdown)
        attributes
      end

      raw_values
    end

    def transform(attributes, uids, function)
      uids.each do |uid|
        next unless attributes.present? && attributes[uid].present?

        attributes[uid] = send(function, attributes[uid])
      end
    end

    def records_query(relation)
      GobiertoCommon::CustomFieldRecord.where(
        custom_field: custom_fields,
        item: relation
      ).sorted.select(:id, :item_id, :payload)
    end

    def versioned_payloads(records, version_index)
      records.map do |record|
        version = record.versions[version_index]
        return {} unless version.present? && version.object?

        JSON.parse(version.object_deserialized&.dig("payload") || "{}")
      end
    end

    def save_with_custom_fields
      return unless resource.save

      initialize_custom_fields_form
      custom_fields_save
    end

    def translate(hash)
      hash = hash.with_indifferent_access
      hash[I18n.locale] || hash[I18n.default_locale] || hash.slice(I18n.available_locales).values&.first || ""
    end

    def meta
      @resource ||= base_relation.new

      return unless stale?(custom_fields) || params[:stats] == "true"

      meta_stats = if params[:stats] == "true"
                     query = GobiertoCommon::CustomFieldsQuery.new(relation: base_relation, custom_fields: custom_fields)
                     filterable_custom_fields.inject({}) do |stats, custom_field|
                       stats.update(
                         custom_field.uid => query.stats(custom_field, filter_params)
                       )
                     end
                   else
                     {}
                   end
      render json: custom_fields, adapter: :json_api, meta: meta_stats, vocabularies_adapter: vocabularies_adapter
    end

    private

    def custom_fields_save
      @custom_fields_form.save
    end

    def filterable_custom_fields
      @filterable_custom_fields ||= if (filterable_custom_fields_uids = current_site.settings_for_module(current_module)&.filterable_custom_fields).present?
                                      custom_fields.where(uid: filterable_custom_fields_uids).sorted
                                    else
                                      custom_fields.where(field_type: [:date, :vocabulary_options, :numeric]).sorted
                                    end
    end

    def initialize_custom_fields_form
      @custom_fields_form = GobiertoCommon::CustomFieldRecordsForm.new(
        site_id: current_site.id,
        item: resource
      )

      return if request.get?

      @custom_fields_form.custom_field_records = params.require(:data).require(:attributes).slice(*custom_field_keys).permit!
    end

    def filter_params
      return unless params[:filter].present?

      filter_query_params = params.require(:filter).slice(*custom_field_keys).permit!.to_h

      filter_query_params.inject({}) do |params, (uid, value)|
        custom_field = custom_fields.find_by_uid(uid)

        next params unless custom_field.present?

        value = { eq: value }.with_indifferent_access unless value.is_a?(Hash)

        value.slice!(*GobiertoCommon::CustomFieldsQuery.allowed_operators)

        if value.has_key?(:in)
          value[:in] = value[:in].split(",")
        end

        record = custom_field.records.new

        params.update(
          custom_field => value.transform_values do |val|
            if val.is_a?(Array)
              val.map do |single_val|
                record.value = single_val
                record.filter_value
              end
            else
              record.value = val
              record.filter_value
            end
          end
        )
      end
    end

    def custom_field_keys
      @custom_field_keys ||= custom_fields.map(&:uid)
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
