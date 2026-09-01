# frozen_string_literal: true

module RackAttackHelpers
  # Rack::Attack is disabled in the test environment. This enables it for the
  # duration of the block with its own cache and its own limits, and restores
  # the configuration afterwards.
  def with_rack_attack(environment = {})
    previous_enabled = Rack::Attack.enabled
    previous_store = Rack::Attack.cache.store

    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.enabled = true

    with_environment(environment) do
      install_rack_attack_rules
      yield
    end
  ensure
    Rack::Attack.enabled = previous_enabled
    Rack::Attack.cache.store = previous_store
    install_rack_attack_rules
  end

  # clear_configuration also restores the default responders, so they have to be
  # assigned again.
  def install_rack_attack_rules
    Rack::Attack.clear_configuration
    Rack::Attack.throttled_responder = ->(request) { RackAttackResponder.throttled(request) }
    Rack::Attack.blocklisted_responder = ->(request) { RackAttackResponder.blocklisted(request) }
    RackAttackRules.install!
  end

  # The internal traffic safelist exempts private addresses, and integration
  # tests default to 127.0.0.1.
  def public_client_headers(ip = "203.0.113.10")
    { "REMOTE_ADDR" => ip }
  end
end
