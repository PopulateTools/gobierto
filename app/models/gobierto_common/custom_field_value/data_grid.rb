# frozen_string_literal: true

module GobiertoCommon::CustomFieldValue
  class DataGrid < Base
    def value
      raw_value&.dig("content")
    end

    def value=(value)
      value = { content: value }
      super
    end

    def raw_value
      super || { content: [] }.with_indifferent_access
    end
  end
end
