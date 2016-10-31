require File.expand_path('../boot', __FILE__)

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"

require "ostruct"

Bundler.require(*Rails.groups)

module RailsTemplate
  class Application < Rails::Application
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :es
    config.i18n.available_locales = [:es, :en]

    config.active_record.raise_in_transactional_callbacks = true

    config.generators do |g|
      g.test_framework :minitest, spec: false, fixture: true
    end

    config.action_dispatch.default_headers.merge!({
      'Access-Control-Allow-Origin' => '*',
      'Access-Control-Request-Method' => '*'
    })

    config.action_mailer.default_url_options = { host: 'gobierto.es', protocol: 'https' }

    config.active_job.queue_adapter = nil

    # Autoloading
    config.autoload_paths += [
      "#{config.root}/lib",
      "#{config.root}/lib/modules",
      "#{config.root}/lib/validators",
      "#{config.root}/lib/constraints"
    ]
  end
end
