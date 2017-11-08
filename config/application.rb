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

    config.action_dispatch.default_headers.merge!("Access-Control-Allow-Origin" => "*",
                                                  "Access-Control-Request-Method" => "*")

    config.active_job.queue_adapter = :async

    # Autoloading
    config.autoload_paths += [
      "#{config.root}/lib",
      "#{config.root}/lib/validators",
      "#{config.root}/lib/constraints",
      "#{config.root}/lib/errors",
      "#{config.root}/lib/ibm_notes"
    ]

    # Do not add wrapper .field_with_errors around form fields with validation errors
    config.action_view.field_error_proc = proc { |html_tag, _instance| html_tag }

    config.time_zone = "Madrid"
  end
end

require_dependency "app/publishers/base"
require_dependency "app/subscribers/base"
