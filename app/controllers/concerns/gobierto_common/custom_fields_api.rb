# frozen_string_literal: true

module GobiertoCommon
  module CustomFieldsApi
    extend ActiveSupport::Concern

    included do
      attr_reader :resource

      serialization_scope :current_site
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

    def custom_field_keys
      current_site.custom_fields.where(class_name: resource.class.name).map(&:uid)
    end

  end
end
