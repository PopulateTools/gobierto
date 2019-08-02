# frozen_string_literal: true

module GobiertoCommon::CustomFieldValidators
  class Table < Base
    VALID_TYPES = %w(text integer float date vocabulary).freeze

    def valid?
      return if custom_field_form.errors[:plugin_configuration].present?

      configuration = JSON.parse(custom_field_form.plugin_configuration)

      return unless configuration&.has_key?("columns")

      configuration["columns"].each do |column_configuration|
        custom_field_form.errors.add(:options, I18n.t("errors.messages.custom_fields.options.wrong_column_type")) unless VALID_TYPES.include? column_configuration["type"]

        if column_configuration["type"] == "vocabulary"
          custom_field_form.errors.add(:options, I18n.t("errors.messages.custom_fields.options.missing_vocabulary")) if column_configuration["dataSource"].blank?
        end

      end
    end

  end
end
