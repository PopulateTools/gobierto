# frozen_string_literal: true

module GobiertoAdmin
  module CustomFieldsHelper
    extend ActiveSupport::Concern

    private

    def initialize_custom_field_form(item = nil)
      custom_params_key = self.class.name.demodulize.gsub("Controller", "").underscore.singularize
      item ||= instance_variable_get("@#{custom_params_key}")

      @custom_fields_form = ::GobiertoAdmin::GobiertoCommon::CustomFieldRecordsForm.new(
        site_id: current_site.id,
        item: item
      )
      return if request.get? || !params.has_key?(custom_params_key)

      @custom_fields_form.custom_field_records = params.require(custom_params_key).permit(custom_records: {})
    end

    def custom_fields_save
      @custom_fields_form.save
    end
  end
end
