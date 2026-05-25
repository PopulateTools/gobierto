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

module RackAttackHelpers
  AGENDAS_PATH_REGEX = %r{\A(?:/[a-z]{2})?/agendas(/|\z)}.freeze
  CALENDAR_PARAMS = %w(date start_date end_date start end).freeze

  def self.agendas_date_out_of_window?(request)
    return false unless request.get?

    today = Date.current
    window = (today - GobiertoPeople::DatesRangeHelper::CALENDAR_WINDOW_PAST_YEARS.years)..
             (today + GobiertoPeople::DatesRangeHelper::CALENDAR_WINDOW_FUTURE_YEARS.years)

    CALENDAR_PARAMS.any? do |key|
      raw = request.params[key]
      next false if raw.blank?

      parsed = Date.parse(raw.to_s) rescue nil
      parsed.nil? || !window.cover?(parsed)
    end
  end
end

Rack::Attack.blocklist("fail2ban agendas bogus dates") do |request|
  next false unless request.path.match?(RackAttackHelpers::AGENDAS_PATH_REGEX)

  Rack::Attack::Fail2Ban.filter("agendas-#{request.ip}", maxretry: 5, findtime: 5.minutes, bantime: 1.hour) do
    RackAttackHelpers.agendas_date_out_of_window?(request)
  end
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
