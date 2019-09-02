# frozen_string_literal: true

module GobiertoCommon
  module CustomFieldsApi
    extend ActiveSupport::Concern

    included do
      attr_reader :resource

      serialization_scope :current_site
    end

    def filtered_relation
      return base_relation unless filter_params.present?

      query = GobiertoCommon::CustomFieldsQuery.new(relation: base_relation)
      query.filter(filter_params)
    end

    def save_with_custom_fields
      return unless resource.save

      initialize_custom_fields_form
      custom_fields_save
    end

    private

    def custom_fields_save
      @custom_fields_form.save
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

        record = custom_field.records.new
        record.value = value
        params.update(
          custom_field => record.filter_value
        )
      end
    end

    def custom_field_keys
      @custom_field_keys ||= custom_fields.map(&:uid)
    end

    def custom_fields
      @custom_fields ||= current_site.custom_fields.for_class(resource.class)
    end

  end
end
