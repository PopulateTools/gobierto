# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

require "ostruct"
require "csv"
require "google/apis/calendar_v3"
require "googleauth"
require "google/api_client/client_secrets"
require "googleauth/stores/file_token_store"
require_relative "../lib/middlewares/override_welcome_action"

Bundler.require(*Rails.groups)

module Gobierto
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults "6.0"

    config.active_record.schema_format = :sql

    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}").to_s]

    config.i18n.default_locale = :es
    config.i18n.available_locales = [:es, :en, :ca]

    config.generators do |g|
      g.test_framework :minitest, spec: false, fixture: true
    end

    # Middlewares
    config.middleware.use I18n::JS::Middleware
    config.middleware.use ::OverrideWelcomeAction

    config.action_dispatch.default_headers.merge!("Access-Control-Allow-Origin" => "*",
                                                  "Access-Control-Request-Method" => "*")

    config.active_job.queue_adapter = :async

    # Required code paths
    required_paths = [
      "#{config.root}/db/seeds",
      "#{config.root}/lib",
      "#{config.root}/lib/validators",
      "#{config.root}/lib/constraints",
      "#{config.root}/lib/middlewares",
      "#{config.root}/lib/utils",
      "#{config.root}/lib/minitest"
    ]
    config.autoload_paths += required_paths
    config.eager_load_paths += required_paths

    # Auth Strategies
    base_strategies_path = %w(vendor auth_strategies)
    available_strategies = Dir.chdir(config.root.join(*base_strategies_path)) do
      Dir.glob("*").select { |file| File.directory?(file) }
    end

    available_strategies.each do |strategy|
      require config.root.join(*base_strategies_path).join(strategy, "lib", "initializer")
    end

    # Engine Overrides
    config.engine_sass_config_overrides = []
    config.engine_sass_theme_dependencies = []
    config.gobierto_engines_themes = {}

    # Custom field plugins
    config.custom_field_plugins = {}
    config.custom_field_plugins_packs = []
    config.plugins_attached_modules = {}

    base_engines_path = %w(vendor gobierto_engines)
    available_engines = Dir.chdir(config.root.join(*base_engines_path)) do
      Dir.glob("*").select { |item| File.directory?(item) }
    end

    available_engines.each do |engine_dir|
      require config.root.join(*base_engines_path).join(engine_dir, "lib", "initializer")
    end

    # Do not add wrapper .field_with_errors around form fields with validation errors
    config.action_view.field_error_proc = proc { |html_tag, _instance| html_tag }

    config.time_zone = "Madrid"

    # if Gobierto runs in a root path, assets should use that path too
    if ENV["GOBIERTO_ROOT_URL_PATH"].present?
      Rails.application.config.relative_url_root = ENV["GOBIERTO_ROOT_URL_PATH"]
    end

    # Redirections
    config.middleware.insert_before(Rack::Runtime, Rack::Rewrite) do
      r301 %r{^/dashboards/contratos(.*)}, '/visualizaciones/contratos$1'
      r301 %r{^/dashboards/subvenciones(.*)}, '/visualizaciones/subvenciones$1'
      r301 %r{^/dashboards/costes(.*)}, '/visualizaciones/costes$1'
    end
  end
end
