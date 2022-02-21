# frozen_string_literal: true

REDIS_CONFIG = { url: ENV.fetch("REDIS_SIDEKIQ_URL", "redis://localhost:6379/0") }.freeze

Sidekiq.logger.level = Rails.logger.level

Sidekiq.configure_server do |config|
  config.redis = REDIS_CONFIG
end

Sidekiq.configure_client do |config|
  config.redis = REDIS_CONFIG
end

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [
    Rails.application.secrets.sidekiq_web_usr,
    Rails.application.secrets.sidekiq_web_pwd
  ]
end
