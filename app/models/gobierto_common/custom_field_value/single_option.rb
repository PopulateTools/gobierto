# frozen_string_literal: true

module GobiertoCommon::CustomFieldValue
  class SingleOption < Base
    def value
      return nil unless custom_field.options.present? && custom_field.options[raw_value.presence].presence

      custom_field.options[raw_value][I18n.locale.to_s]
    end
  end
end
