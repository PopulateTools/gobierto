# frozen_string_literal: true

module GobiertoCommon::CustomFieldValidators
  class Progress < Base

    def valid?
      return if custom_field_form.errors[:plugin_configuration].present?

      configuration = JSON.parse(custom_field_form.plugin_configuration)

      if configuration
        return if all_uids_present?(configuration) && records_respond_to_progress?(configuration)

        custom_field_form.errors.add(:options, I18n.t("errors.messages.custom_fields.options.wrong_custom_field_uids"))
      end
    end

    private

    def all_uids_present?(configuration)
      configuration["custom_field_uids"].blank? ||
        custom_field_form.site.custom_fields.where(uid: configuration["custom_field_uids"]).count == configuration["custom_field_uids"].count
    end

    def records_respond_to_progress?(configuration)
      custom_field_form.site.custom_fields.where(uid: configuration["custom_field_uids"]).all? do |custom_field|
        custom_field.records.new.functions.respond_to?(:progress)
      end
    end

  end
end
