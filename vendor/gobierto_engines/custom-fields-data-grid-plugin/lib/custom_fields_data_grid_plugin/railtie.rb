# frozen_string_literal: true

begin
  require 'rails/railtie'
rescue LoadError
else
  class CustomFieldsDataGridPlugin
    class Railtie < Rails::Railtie
      base_path = File.join(File.dirname(__FILE__), "../..")
      Rails.application.config.tap do |conf|
        conf.custom_field_plugins += %w(indicators human_resources)
        conf.custom_field_plugins_packs += %w(data_grid)
        conf.i18n.load_path += Dir[File.join(base_path, 'config', 'locales', '**', '*.{rb,yml}')]
      end
      Webpacker::Compiler.watched_paths << "app/javascript/plugin/**/*.js"
      Webpacker::Compiler.watched_paths << "app/javascript/packs/*.js"
    end
  end
end
