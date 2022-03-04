# frozen_string_literal: true

require "redis_configuration"
redis_sidekiq_params = RedisConfiguration.new(:sidekiq).dump

$redis = Redis.new(redis_sidekiq_params)
