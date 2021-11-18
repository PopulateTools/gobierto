# frozen_string_literal: true

module GobiertoCommon
  module CustomFieldsApi
    extend ActiveSupport::Concern

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

    def transformed_custom_field_record_values(relation)
      GobiertoCommon::CustomFieldsService.new(
        relation: relation,
        custom_fields: custom_fields,
        cache_service: cache_service
      ).transformed_custom_field_record_values
    end

    def save_with_custom_fields
      return unless resource.save

      initialize_custom_fields_form
      custom_fields_save
    end

    def meta
      @resource ||= base_relation.new

      return unless stale?(custom_fields)

      meta_stats = if params[:stats] == "true"
                     query = GobiertoCommon::CustomFieldsQuery.new(relation: base_relation.unscope(:order), custom_fields: custom_fields)
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
  end
end
