# frozen_string_literal: true

module GobiertoCommon::CustomFieldValue
  class Text < Base
    def raw_value
      return super unless super.is_a?(Hash)

      hash = super.with_indifferent_access
      hash[I18n.locale] || hash[I18n.default_locale] || hash.slice(I18n.available_locales).values&.first || ""
    end
  end
end
