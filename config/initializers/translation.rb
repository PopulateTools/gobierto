TranslationIO.configure do |config|
  config.api_key        = ENV['TRANSLATION_IO_API_KEY']
  config.source_locale  = 'en'
  config.target_locales = ['ca', 'es']
  config.disable_gettext = true

  # Find other useful usage information here:
  # https://github.com/aurels/translation-gem/blob/master/README.md
end
