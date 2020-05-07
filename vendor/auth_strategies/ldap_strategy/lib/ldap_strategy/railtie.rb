# frozen_string_literal: true

begin
  require "rails/railtie"
rescue LoadError
else
  class LdapStrategy
    class Railtie < Rails::Railtie
      config.eager_load_namespaces << LdapStrategy

      Rails.application.secrets.ldap_configurations = File.exists?("vendor/auth_strategies/ldap_strategy/config/config.yml") ?  YAML.load_file("vendor/auth_strategies/ldap_strategy/config/config.yml") : {}
      Rails.application.config.tap do |conf|
        base_strategy_path = conf.root.join("vendor", "auth_strategies", "ldap_strategy")
        conf.paths["app/views"].unshift(base_strategy_path.join("app", "views"))
        conf.i18n.load_path += Dir[base_strategy_path.join("config", "locales", "**", "*.{rb,yml}")]
        conf.autoload_paths += Dir[base_strategy_path.join("lib", "validators")]
        conf.autoload_paths += Dir[base_strategy_path.join("**").join("app", "*")]
      end
    end
  end
end
