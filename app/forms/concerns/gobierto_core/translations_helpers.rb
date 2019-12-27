# frozen_string_literal: true

module GobiertoCore
  module TranslationsHelpers
    extend ActiveSupport::Concern

    def available_locales_blank_translations
      @available_locales_blank_translations ||= begin
                                                  if try(:site).present?
                                                    site.configuration.available_locales.inject({}) do |hash, locale|
                                                      hash.update(
                                                        locale => nil
                                                      )
                                                    end
                                                  else
                                                    { I18n.locale => nil }
                                                  end
                                                end.with_indifferent_access
    end
  end
end
