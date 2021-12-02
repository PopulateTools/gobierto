# frozen_string_literal: true

$redis = Redis.new(url: ENV.fetch("REDIS_SIDEKIQ_URL") { "redis://localhost:6379/0" },
                   namespace: APP_CONFIG[:site][:name])
