# frozen_string_literal: true

require "test_helper"

class RackAttackRulesTest < ActiveSupport::TestCase
  def request_for(path, env = {})
    Rack::Attack::Request.new(Rack::MockRequest.env_for(path, env))
  end

  def test_agendas_path_matches_the_paths_the_routes_expose
    matching = ["/agendas", "/agendas.json", "/agendas/richard", "/agendas/richard.json",
                "/agendas/gobierno", "/en/agendas", "/ca/agendas", "/en/agendas.json"]
    not_matching = ["/agendastuff", "/otras/agendas", "/people-and-agendas", "/"]

    matching.each { |path| assert RackAttackRules::AGENDAS_PATH.match?(path), "expected #{path} to match" }
    not_matching.each { |path| assert_not RackAttackRules::AGENDAS_PATH.match?(path), "expected #{path} not to match" }
  end

  def test_budgets_execution_path_matches_paths_without_a_locale_prefix
    matching = ["/presupuestos/ejecucion", "/presupuestos/ejecucion/2024", "/presupuestos/ejecucion.json"]
    not_matching = ["/presupuestos/partidas", "/es/presupuestos/ejecucion"]

    matching.each { |path| assert RackAttackRules::BUDGETS_EXECUTION_PATH.match?(path), "expected #{path} to match" }
    not_matching.each { |path| assert_not RackAttackRules::BUDGETS_EXECUTION_PATH.match?(path), "expected #{path} not to match" }
  end

  def test_static_path_matches_assets_and_crawler_files
    matching = ["/assets/application.css", "/packs/js/people.js", "/favicon.ico", "/robots.txt", "/sitemap.xml"]

    matching.each { |path| assert RackAttackRules::STATIC_PATH.match?(path), "expected #{path} to match" }
    assert_not RackAttackRules::STATIC_PATH.match?("/agendas")
  end

  def test_client_ip_uses_the_address_resolved_by_action_dispatch
    request = request_for("/agendas", "REMOTE_ADDR" => "172.17.0.1", "HTTP_X_FORWARDED_FOR" => "203.0.113.10")
    request.env["action_dispatch.remote_ip"] = ActionDispatch::RemoteIp::GetIp.new(request, true, [])

    assert_equal "203.0.113.10", RackAttackRules.client_ip(request)
  end

  def test_client_ip_falls_back_to_the_rack_address_when_the_headers_are_contradictory
    request = request_for("/agendas",
                          "REMOTE_ADDR" => "172.17.0.1",
                          "HTTP_CLIENT_IP" => "198.51.100.7",
                          "HTTP_X_FORWARDED_FOR" => "203.0.113.10")
    request.env["action_dispatch.remote_ip"] = ActionDispatch::RemoteIp::GetIp.new(request, false, [])

    assert_equal request.ip, RackAttackRules.client_ip(request)
  end

  def test_client_ip_is_memoized_in_the_rack_environment
    request = request_for("/agendas", "REMOTE_ADDR" => "203.0.113.10")

    assert_equal "203.0.113.10", RackAttackRules.client_ip(request)
    assert_equal "203.0.113.10", request.env[RackAttackRules::CLIENT_IP_KEY]
  end

  def test_private_ip_recognizes_loopback_and_internal_ranges
    ["127.0.0.1", "172.17.0.1", "10.1.2.3", "192.168.0.4", "::1"].each do |ip|
      assert RackAttackRules.private_ip?(ip), "expected #{ip} to be private"
    end

    assert_not RackAttackRules.private_ip?("203.0.113.10")
    assert_not RackAttackRules.private_ip?("not an address")
  end

  def test_safelisted_ip_reads_the_configured_ranges
    with_environment("RACK_ATTACK_SAFELIST_IPS" => "203.0.113.0/24, 198.51.100.7") do
      assert RackAttackRules.safelisted_ip?("203.0.113.10")
      assert RackAttackRules.safelisted_ip?("198.51.100.7")
      assert_not RackAttackRules.safelisted_ip?("192.0.2.1")
    end
  end

  def test_limits_and_periods_can_be_overridden_by_the_environment
    assert_equal RackAttackRules::DEFAULTS["AGENDAS"][:limit], RackAttackRules.limit_for("AGENDAS")

    with_environment("RACK_ATTACK_AGENDAS_LIMIT" => "7", "RACK_ATTACK_AGENDAS_PERIOD" => "30") do
      assert_equal 7, RackAttackRules.limit_for("AGENDAS")
      assert_equal 30.seconds, RackAttackRules.period_for("AGENDAS")
    end
  end

  def test_dates_the_calendar_sends_are_not_bogus
    ["2026-07-26", Date.current.iso8601, "#{Date.current.iso8601}T00:00:00+02:00"].each do |value|
      assert_not RackAttackRules.agendas_bogus_date?(request_for("/agendas?start=#{CGI.escape(value)}")),
                 "expected #{value} to be accepted"
    end
  end

  def test_dates_outside_the_calendar_window_are_bogus
    assert RackAttackRules.agendas_bogus_date?(request_for("/agendas?start_date=1900-01-01"))
    assert RackAttackRules.agendas_bogus_date?(request_for("/agendas?date=4678-12-29"))
    assert RackAttackRules.agendas_bogus_date?(request_for("/agendas?date=not-a-date"))
  end

  def test_unparseable_query_strings_are_bogus_instead_of_raising
    assert RackAttackRules.agendas_bogus_date?(request_for("/agendas?date=1&date[x]=2"))
  end

  def test_requests_without_date_params_are_not_bogus
    assert_not RackAttackRules.agendas_bogus_date?(request_for("/agendas"))
    assert_not RackAttackRules.agendas_bogus_date?(request_for("/agendas?date="))
  end
end
