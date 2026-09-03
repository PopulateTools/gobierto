# frozen_string_literal: true

require "test_helper"

class RackAttackResponderTest < ActiveSupport::TestCase
  def request_for(path, env = {})
    Rack::Attack::Request.new(Rack::MockRequest.env_for(path, env))
  end

  def throttled_request(path, env = {}, match_data = { period: 60, epoch_time: 0, limit: 1, count: 2 })
    request = request_for(path, env)
    request.env["rack.attack.match_data"] = match_data
    request
  end

  def test_locale_comes_from_the_path_prefix
    assert_equal "en", RackAttackResponder.locale_for(request_for("/en/agendas"))
    assert_equal "ca", RackAttackResponder.locale_for(request_for("/ca/agendas"))
  end

  def test_locale_comes_from_the_site_when_the_path_has_no_prefix
    site = sites(:madrid)

    assert_equal site.configuration.default_locale,
                 RackAttackResponder.locale_for(request_for("/agendas", "gobierto_site" => site))
  end

  def test_locale_comes_from_accept_language_when_there_is_no_site
    request = request_for("/agendas", "HTTP_ACCEPT_LANGUAGE" => "ca-ES,ca;q=0.9,es;q=0.8")

    assert_equal "ca", RackAttackResponder.locale_for(request)
  end

  def test_locale_falls_back_to_spanish
    assert_equal "es", RackAttackResponder.locale_for(request_for("/agendas"))
    assert_equal "es", RackAttackResponder.locale_for(request_for("/agendas", "HTTP_ACCEPT_LANGUAGE" => "de,fr;q=0.8"))
  end

  def test_json_is_requested_by_format_header_or_accept
    assert RackAttackResponder.wants_json?(request_for("/agendas.json"))
    assert RackAttackResponder.wants_json?(request_for("/presupuestos/ejecucion.csv"))
    assert RackAttackResponder.wants_json?(request_for("/agendas", "HTTP_X_REQUESTED_WITH" => "XMLHttpRequest"))
    assert RackAttackResponder.wants_json?(request_for("/agendas", "HTTP_ACCEPT" => "application/json"))

    assert_not RackAttackResponder.wants_json?(request_for("/agendas"))
    assert_not RackAttackResponder.wants_json?(request_for("/agendas", "HTTP_ACCEPT" => "text/html,application/json"))
  end

  def test_retry_after_counts_the_seconds_left_in_the_window
    request = throttled_request("/agendas", {}, { period: 60, epoch_time: 130 })

    assert_equal 50, RackAttackResponder.retry_after_for(request)
  end

  def test_retry_after_never_asks_for_an_immediate_retry
    assert_equal RackAttackResponder::MINIMUM_RETRY_AFTER,
                 RackAttackResponder.retry_after_for(throttled_request("/agendas", {}, { period: 60, epoch_time: 59 }))
    assert_equal RackAttackResponder::MINIMUM_RETRY_AFTER,
                 RackAttackResponder.retry_after_for(request_for("/agendas"))
  end

  def test_throttled_html_response
    status, headers, body = RackAttackResponder.throttled(throttled_request("/agendas"))

    assert_equal 429, status
    assert_equal "text/html; charset=utf-8", headers["Content-Type"]
    assert_equal "no-store", headers["Cache-Control"]
    assert_equal "es", headers["Content-Language"]
    assert_equal "60", headers["Retry-After"]
    assert_includes body.first, "Demasiadas peticiones"
    assert_includes body.first, '<html lang="es">'
  end

  def test_throttled_json_response
    status, headers, body = RackAttackResponder.throttled(throttled_request("/agendas.json"))
    payload = JSON.parse(body.first)

    assert_equal 429, status
    assert_equal "application/json; charset=utf-8", headers["Content-Type"]
    assert_equal 429, payload.dig("error", "status")
    assert_equal 60, payload.dig("error", "retry_after")
    assert_includes payload.dig("error", "message"), "demasiadas peticiones"
  end

  def test_blocklisted_response_has_no_retry_after
    status, headers, body = RackAttackResponder.blocklisted(request_for("/presupuestos/ejecucion/-2020"))

    assert_equal 403, status
    assert_nil headers["Retry-After"]
    assert_includes body.first, "Petición no permitida"
  end

  def test_blocklisted_response_is_translated
    status, _headers, body = RackAttackResponder.blocklisted(request_for("/en/agendas"))

    assert_equal 403, status
    assert_includes body.first, "Request not allowed"
  end
end
