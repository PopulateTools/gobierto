# frozen_string_literal: true

begin
  require "rails/railtie"
rescue LoadError
else
  class LdapStrategy
    class Railtie < Rails::Railtie
      config.eager_load_namespaces << LdapStrategy

      Rails.application.config.tap do |conf|
        base_strategy_path = conf.root.join("vendor", "auth_strategies", "ldap_strategy")
        conf.paths["app/views"].unshift(base_strategy_path.join("app", "views"))
        conf.i18n.load_path += Dir[base_strategy_path.join("config", "locales", "**", "*.{rb,yml}")]
        load_paths = Dir[base_strategy_path.join("lib", "validators")]
        load_paths += Dir[base_strategy_path.join("**").join("app", "*")]
        conf.autoload_paths += load_paths
        conf.eager_load_paths += load_paths
      end
    end
  end
end
