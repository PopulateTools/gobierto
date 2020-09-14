# frozen_string_literal: true

def attach_module(config, origin, module_class)
  if config.plugins_attached_modules[origin]
    config.plugins_attached_modules[origin].append(module_class)
  else
    config.plugins_attached_modules[origin] = [module_class]
  end
end

begin
  require 'rails/railtie'
rescue LoadError
else
  class CustomFieldsDataGridPlugin
    class Railtie < Rails::Railtie
      base_path = File.join(File.dirname(__FILE__), "../..")

      Rails.application.config.tap do |conf|
        conf.custom_field_plugins.merge!(budgets: {})
        conf.custom_field_plugins_packs += %w(data_grid)

        load_paths = %w(models decorators).map { |directory| Pathname.new(base_path).join("app", directory) }
        conf.autoload_paths += load_paths
        conf.eager_load_paths += load_paths

        attach_module(conf, "::GobiertoPlans::CategoryTermDecorator", "::GobiertoPlans::CategoryTermDecoratorBudgetsAttachment")

        conf.i18n.load_path += Dir[File.join(base_path, 'config', 'locales', '**', '*.{rb,yml}')]
      end
    end
  end
end
