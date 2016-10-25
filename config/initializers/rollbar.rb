require 'rollbar/rails'

Rollbar.configure do |config|
  config.access_token = Rails.application.secrets.rollbar_access_token

  # Here we'll disable in 'test':
  unless Rails.env.production?
    config.enabled = false
  end

  config.exception_level_filters.merge!({
    'ActionController::InvalidCrossOriginRequest' => 'ignore',
    'ActionController::RoutingError' => 'ignore',
    'ActionController::UnknownFormat' => 'ignore'
  })

end
