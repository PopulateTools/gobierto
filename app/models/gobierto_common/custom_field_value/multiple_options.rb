# frozen_string_literal: true

module GobiertoCommon::CustomFieldValue
  class MultipleOptions < Base
    def value
      super

      return nil unless custom_field.options.present?

      Array(raw_value).map do |v|
        custom_field.options[v][I18n.locale.to_s]
      end
    end
  end
end
