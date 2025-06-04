# frozen_string_literal: true

Rack::Attack.enabled = !Rails.env.test?

Rack::Attack.throttle("requests by ip Tier 1", limit: 50, period: 10.seconds) do |request|
  request.ip
end

Rack::Attack.throttle("requests by ip Tier 2", limit: 500, period: 5.minutes) do |request|
  request.ip
end

Rack::Attack.throttle("requests by ip Tier 3", limit: 1000, period: 24.hours) do |request|
  request.ip
end

ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, req|
  if [:throttle].include? req.env['rack.attack.match_type']
    Rails.logger.info("[rack_attack] #{req.env['rack.attack.match_type']} #{req.ip} #{req.request_method} #{req.fullpath}")
  end
end
