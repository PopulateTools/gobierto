# frozen_string_literal: true

require_relative "../../lib/middlewares/rack_attack_rules"
require_relative "../../lib/middlewares/rack_attack_responder"

Rack::Attack.enabled = RackAttackRules.enabled?
Rack::Attack.throttled_responder = ->(request) { RackAttackResponder.throttled(request) }
Rack::Attack.blocklisted_responder = ->(request) { RackAttackResponder.blocklisted(request) }

RackAttackRules.install!

# One subscriber for every event type. The rule name lives in
# env["rack.attack.matched"]: without it every rule writes the same line and
# there is no way to tell from a log which limit a client hit.
ActiveSupport::Notifications.subscribe(/\.rack_attack\z/) do |_name, _start, _finish, _id, payload|
  request = payload[:request]
  env = request.env
  match_type = env["rack.attack.match_type"].to_s
  match_data = env["rack.attack.match_data"] || {}

  # Safelisted requests are the common case; counting them is useful, logging
  # them would drown the log.
  unless match_type == "safelist"
    fields = {
      event: match_type,
      rule: env["rack.attack.matched"],
      discriminator: env["rack.attack.match_discriminator"],
      count: match_data[:count],
      limit: match_data[:limit],
      period: match_data[:period],
      client_ip: RackAttackRules.client_ip(request),
      rack_ip: request.ip,
      x_forwarded_for: request.get_header("HTTP_X_FORWARDED_FOR"),
      cf_connecting_ip: request.get_header("HTTP_CF_CONNECTING_IP"),
      host: request.host,
      method: request.request_method,
      path: request.fullpath.to_s.slice(0, 300),
      user_agent: request.user_agent.to_s.slice(0, 200)
    }.compact

    Rails.logger.info("[rack_attack] #{fields.map { |key, value| "#{key}=#{value.to_s.inspect}" }.join(" ")}")
  end

  if defined?(::Appsignal) && ::Appsignal.respond_to?(:increment_counter)
    # Tags stay low cardinality: the host is a customer domain and there are
    # hundreds of them, so it belongs in the log, not in a metric tag.
    ::Appsignal.increment_counter(
      "rack_attack_matches",
      1,
      rule: env["rack.attack.matched"].to_s,
      type: match_type
    )
  end
end
