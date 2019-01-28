# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

require "ostruct"
require "csv"
require "google/apis/calendar_v3"
require "googleauth"
require "google/api_client/client_secrets"
require "googleauth/stores/file_token_store"

Bundler.require(*Rails.groups)

module Gobierto
  class Application < Rails::Application
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}").to_s]

    config.i18n.default_locale = :es
    config.i18n.available_locales = [:es, :en, :ca]

    config.generators do |g|
      g.test_framework :minitest, spec: false, fixture: true
    end

    config.middleware.use I18n::JS::Middleware

    config.action_dispatch.default_headers.merge!("Access-Control-Allow-Origin" => "*",
                                                  "Access-Control-Request-Method" => "*")

    config.active_job.queue_adapter = :async

    # Required code paths
    required_paths = [
      "#{config.root}/lib",
      "#{config.root}/lib/validators",
      "#{config.root}/lib/constraints",
      "#{config.root}/lib/errors",
      "#{config.root}/lib/ibm_notes",
      "#{config.root}/lib/liquid"
    ]
    config.autoload_paths += required_paths
    config.eager_load_paths += required_paths

    # Auth Strategies
    base_strategies_path = %w(vendor auth_strategies)
    available_strategies = Dir.chdir(config.root.join(*base_strategies_path)) do
      Dir.glob("*").select { |file| File.directory?(file) }
    end

    available_strategies.each do |strategy|
      require_dependency config.root.join(*base_strategies_path).join(strategy, "lib", "initializer")
    end

    # Engine Overrides
    config.engine_sass_config_overrides = []
    config.engine_sass_theme_dependencies = []
    config.gobierto_engines_themes = {}

    base_engines_path = %w(vendor gobierto_engines)
    available_engines = Dir.chdir(config.root.join(*base_engines_path)) do
      Dir.glob("*").select { |item| File.directory?(item) }
    end

    available_engines.each do |engine_dir|
      require_dependency config.root.join(*base_engines_path).join(engine_dir, "lib", "initializer")
    end

    # Do not add wrapper .field_with_errors around form fields with validation errors
    config.action_view.field_error_proc = proc { |html_tag, _instance| html_tag }

    config.time_zone = "Madrid"

    # if Gobierto runs in a root path, assets should use that path too
    if ENV["GOBIERTO_ROOT_URL_PATH"].present?
      Rails.application.config.relative_url_root = ENV["GOBIERTO_ROOT_URL_PATH"]
    end
  end
end

require_dependency "app/publishers/base"
require_dependency "app/subscribers/base"
