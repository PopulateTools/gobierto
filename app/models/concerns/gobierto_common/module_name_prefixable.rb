# frozen_string_literal: true

module GobiertoCommon
  module ModuleNamePrefixable
    extend ActiveSupport::Concern

    module ClassMethods
      def module_key
        @module_key ||= name.underscore.split("/")[-2].gsub("gobierto_", "")
      end

      def module_name_translations
        @module_name_translations ||= I18n.available_locales.map do |locale|
          [locale, I18n.with_locale(locale) { I18n.t("gobierto_admin.layouts.application.modules.#{module_key}") }]
        end.to_h.symbolize_keys
      end

      def prefix_translations(translations)
        translations.each_with_object({}) do |(locale, translation), prefixed_translations|
          prefixed_translations[locale] = "#{module_name_translations[locale.to_sym]} - #{translation}"
        end
      end
    end
  end
end
