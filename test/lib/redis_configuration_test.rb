# frozen_string_literal: true

require "test_helper"

class RedisConfigurationTest < ActiveSupport::TestCase
  def test_dump_for_sidekiq
    with_environment({
      'REDIS_SIDEKIQ_PASSWORD' => 'password123',
      'REDIS_SIDEKIQ_CA_FILE' => 'path/to/cert.crt',
      'REDIS_SIDEKIQ_URL' => 'redis://localhost:6379/2'
    }) do
      @configuration = RedisConfiguration.new(:sidekiq)

      assert_equal(
        {
          url: 'redis://localhost:6379/2',
          password: 'password123',
          ssl_params: { ca_file: 'path/to/cert.crt' }
        },
        @configuration.dump
      )
    end
  end

  def test_dump_for_sidekiq_with_no_password
    with_environment({
      'REDIS_SIDEKIQ_CA_FILE' => 'path/to/cert.crt',
      'REDIS_SIDEKIQ_URL' => 'redis://localhost:6379/2'
    }) do
      @configuration = RedisConfiguration.new(:sidekiq)

      assert_equal(
        {
          url: 'redis://localhost:6379/2',
          ssl_params: { ca_file: 'path/to/cert.crt' }
        },
        @configuration.dump
      )
    end
  end


  def test_invalid_scope
    assert_raises(ArgumentError) do
      RedisConfiguration.new(:invalid)
    end
  end
end
