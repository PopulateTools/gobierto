# frozen_string_literal: true

TranslationIO.configure do |config|
  config.api_key = ENV["TRANSLATION_IO_API_KEY"]
  config.source_locale = "en"
  config.target_locales = %w(ca es)
  config.disable_gettext = true
  config.ignored_key_prefixes = [
    "i18n_tasks.",
    "number.",
    "spree.",
    "cookies_eu."
  ]

  # Find other useful usage information here:
  # https://github.com/aurels/translation-gem/blob/master/README.md
end
