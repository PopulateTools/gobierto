# frozen_string_literal: true

begin
  require 'rails/railtie'
rescue LoadError
else
  class CustomFieldsDataGridPlugin
    class Railtie < Rails::Railtie
      base_path = File.join(File.dirname(__FILE__), "../..")
      Rails.application.config.tap do |conf|
        conf.custom_field_plugins.merge!(
          indicators: { requires_vocabulary: true },
          human_resources: { requires_vocabulary: true },
          budgets: {}
        )
        conf.custom_field_plugins_packs += %w(data_grid)
        conf.autoload_paths += Dir[Pathname.new(base_path).join('app', 'models')]
        conf.eager_load_paths += Dir[Pathname.new(base_path).join("app", "models")]
        conf.i18n.load_path += Dir[File.join(base_path, 'config', 'locales', '**', '*.{rb,yml}')]
      end
      Webpacker::Compiler.watched_paths += [
        "app/javascript/packs/*.js",
        "app/javascript/custom_fields_data_grid_plugin/*.js",
        "app/javascript/custom_fields_data_grid_plugin/**/*.js"
      ]
    end
  end
end
