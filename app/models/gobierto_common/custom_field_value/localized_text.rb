# frozen_string_literal: true

module GobiertoCommon::CustomFieldValue
  class LocalizedText < Base
    def value
      raw_value[I18n.locale.to_s]
    end

    def searchable_value
      raw_value
    end

    def raw_value
      super || {}
    end
  end
end
