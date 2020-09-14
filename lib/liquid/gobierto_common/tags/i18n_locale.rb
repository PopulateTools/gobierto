# frozen_string_literal: true

module Liquid
  module GobiertoCommon
    module Tags
      class I18nLocale < Liquid::Tag
        def render(context)
          ::I18n.locale
        end
      end
    end
  end
end

Liquid::Template.register_tag("i18n_locale", Liquid::GobiertoCommon::Tags::I18nLocale)
