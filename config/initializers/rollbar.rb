# frozen_string_literal: true

require "rollbar/rails"

def rollbar_enabled?
  Rails.env.staging? || Rails.env.production?
end

Rollbar.configure do |config|
  config.access_token = Rails.application.secrets.rollbar_access_token
  config.enabled = rollbar_enabled?
  config.exception_level_filters.merge!("ActionController::InvalidCrossOriginRequest" => "ignore",
                                        "ActionController::RoutingError" => "ignore",
                                        "ActionController::UnknownFormat" => "ignore")
  config.js_enabled = rollbar_enabled? && Rails.application.secrets.rollbar_post_client_item.present?
  config.js_options = {
    accessToken: Rails.application.secrets.rollbar_post_client_item,
    captureUncaught: true,
    payload: { environment: Rails.env }
  }
end
