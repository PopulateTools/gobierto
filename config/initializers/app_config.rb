# frozen_string_literal: true

APP_CONFIG = Rails.application.config_for(:application).with_indifferent_access

SITE_MODULES = APP_CONFIG[:site_modules].union(Rails.configuration.engine_modules).map do |site_module|
  site_module[:namespace]
end

AUTH_MODULES = APP_CONFIG[:auth_modules].map do |auth_module|
  OpenStruct.new(auth_module)
end

DEFAULT_MISSING_MODULES = AUTH_MODULES.select(&:default)
