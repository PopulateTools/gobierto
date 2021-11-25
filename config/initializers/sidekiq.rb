# frozen_string_literal: true

Sidekiq.logger.level = Rails.logger.level

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_SIDEKIQ_URL") { "redis://localhost:6379/0" } }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_SIDEKIQ_URL") { "redis://localhost:6379/0" } }
end

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [
    Rails.application.secrets.sidekiq_web_usr,
    Rails.application.secrets.sidekiq_web_pwd
  ]
end