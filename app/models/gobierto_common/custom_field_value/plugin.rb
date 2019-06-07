# frozen_string_literal: true

module GobiertoCommon::CustomFieldValue
  class Plugin < Base
    def value
      raw_value&.dig("content")
    end

    def value=(value)
      value = { content: value }
      super
    end

    def raw_value
      super || { content: [].to_json }.with_indifferent_access
    end

    def plugin_name
      custom_field.options.plugin_name
    end
  end
end
