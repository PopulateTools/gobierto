# frozen_string_literal: true

module GobiertoCommon::CustomFieldValue
  class MarkdownText < Text

    include GobiertoHelper

    def value
      return unless custom_field && payload.present?

      markdown(raw_value)
    end
    alias raw_api_value value

    def value_string
      return "" unless value

      raw_value
    end

  end
end
