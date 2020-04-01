# frozen_string_literal: true

module GobiertoCommon::CustomFieldValue
  class LocalizedMarkdownText < LocalizedText

    include GobiertoHelper

    def value
      markdown(value_string) || ""
    end

    def value_string
      raw_value[I18n.locale.to_s] ||
        raw_value[I18n.default_locale.to_s] ||
        raw_value.slice(*I18n.available_locales.map(&:to_s)).values.first
    end

  end
end
