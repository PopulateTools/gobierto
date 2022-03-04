# frozen_string_literal: true

class RedisConfiguration
  # @scope valid values are :sidekiq and :cache
  def initialize(scope)
    @preffix = scope.to_s.upcase
    raise ArgumentError, "Invalid scope #{scope}" unless %w[sidekiq cache].include?(scope.to_s)
    @redis_password = ENV.fetch("REDIS_#{@preffix}_PASSWORD") { "" }
    @redis_ca_file = ENV.fetch("REDIS_#{@preffix}_CA_FILE") { "" }
  end

  def dump
    redis_cache_params = { url: ENV["REDIS_#{@preffix}_URL"] }
    redis_cache_params.merge!({password: @redis_password}) unless @redis_password.blank?
    redis_cache_params.merge!({ssl_params: {ca_file: @redis_ca_file}}) unless @redis_ca_file.blank?

    redis_cache_params
  end
end
