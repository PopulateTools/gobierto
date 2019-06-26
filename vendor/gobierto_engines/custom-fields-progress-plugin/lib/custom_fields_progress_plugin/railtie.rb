# frozen_string_literal: true

begin
  require "rails/railtie"
rescue LoadError
else
  class CustomFieldsProgressPlugin
    class Railtie < Rails::Railtie
      base_path = File.join(File.dirname(__FILE__), "../..")
      Rails.application.config.tap do |conf|
        conf.custom_field_plugins.merge!(
          progress: {
            requires_vocabulary: false,
            has_configuration: true,
            default_configuration: { "custom_field_ids": [], "custom_field_uids": [] },
            callbacks: [:update_progress!]
          }
        )
        conf.custom_field_plugins_packs += %w(progress)
        conf.autoload_paths += Dir[Pathname.new(base_path).join("app", "models")]
        conf.eager_load_paths += Dir[Pathname.new(base_path).join("app", "models")]
        conf.i18n.load_path += Dir[File.join(base_path, "config", "locales", "**", "*.{rb,yml}")]
      end

      rake_tasks do
        Dir[Pathname.new(base_path).join("lib", "tasks", "*.rake")].each do |task|
          load task
        end
      end
      Webpacker::Compiler.watched_paths << "app/javascript/custom_fields_progress_plugin/**/*.js"
      Webpacker::Compiler.watched_paths << "app/javascript/packs/*.js"
    end
  end
end
