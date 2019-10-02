# frozen_string_literal: true

module GobiertoCommon::CustomFieldValue
  class Plugin < Base

    def value=(raw_payload)
      record.payload = JSON.parse(raw_payload)
    rescue JSON::ParserError, TypeError
      record.payload = raw_payload
    end

    def raw_value
      payload.present? ? payload : {}.with_indifferent_access
    end

    def value
      return raw_value unless raw_value.is_a?(Hash) && raw_value.has_key?(custom_field.uid)

      raw_value[custom_field.uid]
    end

    def plugin_name
      custom_field.options.plugin_name
    end

  end
end
