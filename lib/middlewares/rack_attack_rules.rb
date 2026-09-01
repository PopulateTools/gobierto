# frozen_string_literal: true

# Policy for Rack::Attack: which requests are exempt from rate limiting, which
# are limited, and with what budget. Installed from
# config/initializers/rack_attack.rb.
#
# Every limit and period reads an environment variable, so a limit can be
# widened, narrowed or switched off in production with a config change and a
# restart, without a deploy.
module RackAttackRules
  # Agenda routes are declared with a string path, so route_translator leaves
  # the segment untranslated and only adds the locale prefix. The trailing group
  # accepts "." so that /agendas.json is covered too.
  AGENDAS_PATH = %r{\A(?:/(?:es|en|ca))?/agendas(?:[/.]|\z)}.freeze

  # gobierto_budgets is not inside `localized do`, so its paths never carry a
  # locale prefix.
  BUDGETS_EXECUTION_PATH = %r{\A/presupuestos/ejecucion(?:[/.]|\z)}.freeze
  NEGATIVE_YEAR_PATH = %r{\A/presupuestos/ejecucion/-\d+\z}.freeze

  STATIC_PATH = %r{\A/(?:assets|packs|fonts|images|javascripts|stylesheets)/|\A/(?:favicon|robots\.txt|sitemap)}.freeze

  CLIENT_IP_KEY = "gobierto.client_ip"

  DEFAULTS = {
    "REQ_BURST" => { limit: 240, period: 60 },
    "REQ_SUSTAINED" => { limit: 4000, period: 3600 },
    "AGENDAS" => { limit: 90, period: 60 },
    "AGENDAS_BOGUS_DATE" => { limit: 10, period: 3600 },
    "BUDGETS_EXECUTION" => { limit: 60, period: 60 }
  }.freeze

  class << self
    def install!
      install_safelists
      install_blocklists
      install_throttles
    end

    def enabled?
      return ENV["RACK_ATTACK_ENABLED"] == "true" if ENV.key?("RACK_ATTACK_ENABLED")

      Rails.env.production? || Rails.env.staging?
    end

    def limit_for(key)
      Integer(ENV.fetch("RACK_ATTACK_#{key}_LIMIT") { DEFAULTS.fetch(key)[:limit] })
    end

    def period_for(key)
      Integer(ENV.fetch("RACK_ATTACK_#{key}_PERIOD") { DEFAULTS.fetch(key)[:period] }).seconds
    end

    # Parsed once per configured value: this runs on every request.
    def safelisted_ranges
      configured = ENV.fetch("RACK_ATTACK_SAFELIST_IPS", "")
      return @safelisted_ranges if @safelisted_ranges_source == configured

      @safelisted_ranges_source = configured
      @safelisted_ranges = configured.split(",").filter_map do |entry|
        IPAddr.new(entry.strip) rescue nil
      end
    end

    # Rack::Attack is appended at the end of the middleware stack, so
    # ActionDispatch::RemoteIp has already resolved the client address. Use its
    # result, the same one ApplicationConcern#remote_ip records in the audit
    # trail, so a throttle log line and an audited action name the same address.
    #
    # calculate_ip raises IpSpoofAttackError on contradictory headers, and both
    # headers are supplied by the client. An unrescued raise here is a 500.
    def client_ip(request)
      env = request.env
      return env[CLIENT_IP_KEY] if env.key?(CLIENT_IP_KEY)

      env[CLIENT_IP_KEY] = begin
        env["action_dispatch.remote_ip"].try(:calculate_ip).presence || request.ip
      rescue StandardError
        request.ip
      end
    end

    def private_ip?(ip)
      return true if ip.blank?

      address = IPAddr.new(ip)
      ActionDispatch::RemoteIp::TRUSTED_PROXIES.any? { |proxy| proxy.include?(address) }
    rescue IPAddr::Error, ArgumentError
      false
    end

    def safelisted_ip?(ip)
      return false if ip.blank?

      address = IPAddr.new(ip)
      safelisted_ranges.any? { |range| range.include?(address) }
    rescue IPAddr::Error, ArgumentError
      false
    end

    def read_request?(request)
      request.get? || request.head?
    end

    # Same window and same parser as
    # GobiertoPeople::DatesRangeHelper#calendar_date_params_within_window?, so
    # the middleware and the controller cannot disagree about what is out of
    # range.
    def agendas_bogus_date?(request)
      window = GobiertoPeople::DatesRangeHelper.calendar_date_window

      GobiertoPeople::DatesRangeHelper::CALENDAR_WINDOW_PARAM_NAMES.any? do |key|
        raw = request.GET[key]
        next false if raw.blank?

        parsed = Time.zone.parse(raw.to_s) rescue nil
        parsed.nil? || !window.cover?(parsed.to_date)
      end
    rescue Rack::QueryParser::ParameterTypeError, Rack::QueryParser::InvalidParameterError
      # A query string such as ?date=1&date[x]=2 cannot be parsed at all. It is
      # not a calendar request a browser makes, and letting the exception escape
      # a middleware means a 500.
      true
    end

    private

    def install_safelists
      # Assets are normally served from asset_host, but if the app ever serves
      # them a single page load would spend dozens of requests of the budget.
      Rack::Attack.safelist("static files") do |request|
        STATIC_PATH.match?(request.path)
      end

      # Deploy checks, container to container traffic and probes. There is no
      # public client behind these to rate limit.
      Rack::Attack.safelist("internal traffic") do |request|
        private_ip?(client_ip(request))
      end

      # Incident response: exempt the egress address of an affected customer
      # while their limit is fixed properly.
      Rack::Attack.safelist("configured ip allowlist") do |request|
        safelisted_ip?(client_ip(request))
      end
    end

    def install_blocklists
      # No legitimate link carries a negative year. The controller redirects
      # them anyway; this keeps the volume out of Rails.
      Rack::Attack.blocklist("negative year budget execution paths") do |request|
        NEGATIVE_YEAR_PATH.match?(request.path)
      end
    end

    def install_throttles
      # Configuration#throttled? stops at the first rule whose limit is
      # exceeded, so registering the path rules first means the log names the
      # most specific rule. A rule that returns no discriminator never touches
      # the cache, so a request outside those paths still costs two counters.
      throttle("agendas by ip", "AGENDAS") do |request|
        client_ip(request) if read_request?(request) && AGENDAS_PATH.match?(request.path)
      end

      throttle("agendas with bogus dates by ip", "AGENDAS_BOGUS_DATE") do |request|
        if read_request?(request) && AGENDAS_PATH.match?(request.path) && agendas_bogus_date?(request)
          client_ip(request)
        end
      end

      throttle("budgets execution by ip", "BUDGETS_EXECUTION") do |request|
        client_ip(request) if read_request?(request) && BUDGETS_EXECUTION_PATH.match?(request.path)
      end

      throttle("requests by ip burst", "REQ_BURST") { |request| client_ip(request) }
      throttle("requests by ip sustained", "REQ_SUSTAINED") { |request| client_ip(request) }
    end

    def throttle(name, key, &block)
      Rack::Attack.throttle(name, { limit: limit_for(key), period: period_for(key) }, &block)
    end
  end
end
