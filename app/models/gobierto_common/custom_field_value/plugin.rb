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
    alias value raw_value

    def plugin_name
      custom_field.options.plugin_name
    end

  end
end
