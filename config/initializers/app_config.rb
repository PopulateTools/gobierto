# frozen_string_literal: true

APP_CONFIG = Rails.application.config_for(:application).with_indifferent_access

SITE_MODULES = APP_CONFIG["site_modules"].map do |site_module|
  site_module["namespace"]
end
