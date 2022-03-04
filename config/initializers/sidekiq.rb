# frozen_string_literal: true

require "redis_configuration"
redis_sidekiq_params = RedisConfiguration.new(:sidekiq).dump

Sidekiq.logger.level = Rails.logger.level

Sidekiq.configure_server do |config|
  config.redis = redis_sidekiq_params
end

Sidekiq.configure_client do |config|
  config.redis = redis_sidekiq_params
end

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [
    Rails.application.secrets.sidekiq_web_usr,
    Rails.application.secrets.sidekiq_web_pwd
  ]
end
