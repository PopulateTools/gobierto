# frozen_string_literal: true

Rack::Attack.enabled = true

Rack::Attack.throttle("requests by ip Tier 1", limit: 50, period: 10.seconds) do |request|
  request.ip
end

Rack::Attack.throttle("requests by ip Tier 2", limit: 500, period: 5.minutes) do |request|
  request.ip
end

Rack::Attack.throttle("requests by ip Tier 3", limit: 1000, period: 24.hours) do |request|
  request.ip
end
