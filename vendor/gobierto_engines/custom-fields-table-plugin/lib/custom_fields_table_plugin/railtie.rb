# frozen_string_literal: true

require_relative "../../app/decorators/gobierto_plans/category_term_decorator_table_attachment"

def attach_module(config, origin, module_class)
  if config.plugins_attached_modules[origin]
    config.plugins_attached_modules[origin].append(module_class)
  else
    config.plugins_attached_modules[origin] = [module_class]
  end
end

begin
  require "rails/railtie"
rescue LoadError
else
  class CustomFieldsTablePlugin
    class Railtie < Rails::Railtie
      base_path = File.join(File.dirname(__FILE__), "../..")
      Rails.application.config.tap do |conf|
        conf.custom_field_plugins.merge!(
          table: {
            requires_vocabulary: false,
            has_configuration: true,
            default_configuration: { "columns": [] },
            position: 0
          }
        )
        conf.custom_field_plugins_packs += %w(table)
        conf.autoload_paths += Dir[Pathname.new(base_path).join("app", "models")]
        conf.eager_load_paths += Dir[Pathname.new(base_path).join("app", "models")]

        attach_module(conf, "::GobiertoPlans::CategoryTermDecorator", ::GobiertoPlans::CategoryTermDecoratorTableAttachment)

        conf.i18n.load_path += Dir[File.join(base_path, "config", "locales", "**", "*.{rb,yml}")]
      end

      rake_tasks do
        Dir[Pathname.new(base_path).join("lib", "tasks", "custom_field_plugins", "**", "*.rake")].each do |task|
          load task
        end
      end
      Webpacker::Compiler.watched_paths << "app/javascript/custom_fields_table_plugin/**/*.js"
      Webpacker::Compiler.watched_paths << "app/javascript/packs/*.js"
    end
  end
end
