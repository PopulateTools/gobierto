# frozen_string_literal: true

begin
  require 'rails/railtie'
rescue LoadError
else
  class NullStrategy
    class Railtie < Rails::Railtie
      config.eager_load_namespaces << NullStrategy

      Rails.application.config.tap do |conf|
        base_strategy_path = conf.root.join('vendor', 'auth_strategies', 'null_strategy')
        conf.paths['app/views'].unshift(base_strategy_path.join('app', 'views'))
        conf.i18n.load_path += Dir[base_strategy_path.join('config', 'locales', '**', '*.{rb,yml}')]
        conf.autoload_paths += Dir[base_strategy_path.join('lib', 'validators')]
        conf.autoload_paths += Dir[base_strategy_path.join('**').join('app', '*')]
      end
    end
  end
end
