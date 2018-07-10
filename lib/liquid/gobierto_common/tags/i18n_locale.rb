# frozen_string_literal: true

class I18nLocale < Liquid::Tag
  def render(context)
    I18n.locale
  end
end

Liquid::Template.register_tag("i18n_locale", I18nLocale)
