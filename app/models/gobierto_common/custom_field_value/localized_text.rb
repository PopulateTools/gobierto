# frozen_string_literal: true

module GobiertoCommon::CustomFieldValue
  class LocalizedText < Base
    def value
      value = raw_value[I18n.locale.to_s] || raw_value[I18n.default_locale.to_s]
      return value if value.present?
      I18n.available_locales.each do |locale|
        value = raw_value[locale.to_s]
        return value if value.present?
      end
    end

    def searchable_value
      raw_value
    end

    def raw_value
      super || {}
    end
  end
end
