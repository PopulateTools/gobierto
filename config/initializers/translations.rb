# frozen_string_literal: true

require "i18n/backend/gobierto"
require "i18n/backend/fallbacks"
require "i18n/backend/gobierto/memoize"

I18n::Backend::Gobierto.configure do |config|
  config.cleanup_with_destroy = true # defaults to false
end

module I18n
  module JS
    def self.translations
      ::I18n::Backend::Simple.new.instance_eval do
        init_translations unless initialized?
        Private::HashWithSymbolKeys.new(translations)
                                   .slice(*::I18n.available_locales)
                                   .to_h
      end
    end
  end
end

Translation = I18n::Backend::Gobierto::Translation

begin
  if Translation.table_exists?
    I18n.backend = I18n::Backend::Gobierto.new

    I18n::Backend::Gobierto.send(:include, I18n::Backend::GobiertoCore::Memoize)
    I18n::Backend::Simple.send(:include, I18n::Backend::GobiertoCore::Memoize)
    I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)
    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)

    I18n.backend = I18n::Backend::Chain.new(I18n.backend, I18n::Backend::Simple.new)
  end
rescue ActiveRecord::NoDatabaseError
  puts $!
end

I18n.fallbacks.map(ca: :es)
I18n.fallbacks.map(es: :ca)
I18n.fallbacks.map(en: :es)

