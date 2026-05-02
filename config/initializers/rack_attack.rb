# frozen_string_literal: true

Rack::Attack.enabled = !Rails.env.test?

Rack::Attack.blocklist("block negative-year budget execution paths") do |request|
  request.path.match?(%r{\A(?:/[a-z]{2})?/presupuestos/ejecucion/-\d+\z})
end

Rack::Attack.throttle("requests by ip Tier 1", limit: 20, period: 10.seconds) do |request|
  request.ip
end

Rack::Attack.throttle("budgets execution by ip", limit: 10, period: 10.seconds) do |request|
  request.ip if request.path.match?(%r{\A(?:/[a-z]{2})?/presupuestos/ejecucion(/|\z)})
end

Rack::Attack.throttle("agendas by ip", limit: 10, period: 10.seconds) do |request|
  request.ip if request.path.match?(%r{\A(?:/[a-z]{2})?/agendas(/|\z)})
end

Rack::Attack.throttle("requests by ip hourly", limit: 1000, period: 1.hour) do |request|
  request.ip
end

ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |name, start, finish, instrumenter_id, payload|
  Rails.logger.info("[rack_attack] #{payload[:request].ip} #{payload[:request].request_method} #{payload[:request].fullpath}")
end

ActiveSupport::Notifications.subscribe("blocklist.rack_attack") do |name, start, finish, instrumenter_id, payload|
  Rails.logger.info("[rack_attack blocklist] #{payload[:request].ip} #{payload[:request].request_method} #{payload[:request].fullpath}")
end
