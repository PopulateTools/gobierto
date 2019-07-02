# frozen_string_literal: true

require_relative "../../app/decorators/gobierto_plans/category_term_decorator_budgets_attachment"
require_relative "../../app/decorators/gobierto_plans/category_term_decorator_indicators_attachment"
require_relative "../../app/decorators/gobierto_plans/category_term_decorator_human_resources_attachment"

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
        conf.custom_field_plugins.merge!(
          indicators: { requires_vocabulary: true },
          human_resources: { requires_vocabulary: true },
          budgets: {}
        )
        conf.custom_field_plugins_packs += %w(data_grid)

        conf.autoload_paths += Dir[Pathname.new(base_path).join('app', 'models')]
        conf.eager_load_paths += Dir[Pathname.new(base_path).join("app", "models")]

        attach_module(conf, "::GobiertoPlans::CategoryTermDecorator", ::GobiertoPlans::CategoryTermDecoratorBudgetsAttachment)
        attach_module(conf, "::GobiertoPlans::CategoryTermDecorator", ::GobiertoPlans::CategoryTermDecoratorIndicatorsAttachment)
        attach_module(conf, "::GobiertoPlans::CategoryTermDecorator", ::GobiertoPlans::CategoryTermDecoratorHumanResourcesAttachment)

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
