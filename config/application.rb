require_relative 'boot'

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

Bundler.require(*Rails.groups)

module Gobierto
  class Application < Rails::Application
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :es
    config.i18n.available_locales = [:es, :en, :ca]

    config.generators do |g|
      g.test_framework :minitest, spec: false, fixture: true
    end

    config.action_dispatch.default_headers.merge!({
      'Access-Control-Allow-Origin' => '*',
      'Access-Control-Request-Method' => '*'
    })

    config.active_job.queue_adapter = :async

    # Autoloading
    config.autoload_paths += [
      "#{config.root}/lib",
      "#{config.root}/lib/validators",
      "#{config.root}/lib/constraints",
      "#{config.root}/lib/errors",
      "#{config.root}/lib/ibm_notes",
      "#{config.root}/app/pub_sub",
      "#{config.root}/app/pub_sub/publishers",
      "#{config.root}/app/pub_sub/subscribers"
    ]

    # Do not add wrapper .field_with_errors around form fields with validation errors
    config.action_view.field_error_proc = Proc.new { |html_tag, instance| html_tag }

    config.time_zone = 'Madrid'
  end
end

