# frozen_string_literal: true

require "test_helper"

class RackAttackTest < ActionDispatch::IntegrationTest
  def site
    @site ||= sites(:madrid)
  end

  # Integration tests re-raise instead of rendering the error response, which
  # hides the status code a client would actually receive.
  def with_rescued_exceptions
    original = Rails.application.env_config["action_dispatch.show_exceptions"]
    Rails.application.env_config["action_dispatch.show_exceptions"] = true
    yield
  ensure
    Rails.application.env_config["action_dispatch.show_exceptions"] = original
  end

  def test_search_as_you_type_burst_is_not_throttled
    with_current_site(site) do
      with_rack_attack do
        # The autocomplete sends one request per keystroke, so a single query is
        # a burst of about twenty requests in a few seconds.
        25.times { |index| get "/api/v1/search", params: { query: "presupuesto"[0, 3] + index.to_s }, headers: public_client_headers }

        assert_not_equal 429, response.status
      end
    end
  end

  def test_calendar_navigation_is_not_throttled
    with_current_site(site) do
      with_rack_attack do
        20.times do |index|
          get "/agendas.json", params: { start_date: index.months.ago.to_date.iso8601 }, headers: public_client_headers
        end

        assert_not_equal 429, response.status
      end
    end
  end

  def test_localized_agendas_path_is_throttled
    with_current_site(site) do
      with_rack_attack("RACK_ATTACK_AGENDAS_LIMIT" => "2") do
        2.times { get "/ca/agendas.json", headers: public_client_headers }
        get "/ca/agendas.json", headers: public_client_headers

        assert_response :too_many_requests
      end
    end
  end

  def test_agendas_json_path_is_throttled
    with_current_site(site) do
      with_rack_attack("RACK_ATTACK_AGENDAS_LIMIT" => "2") do
        3.times { get "/agendas.json", headers: public_client_headers }

        assert_response :too_many_requests
      end
    end
  end

  def test_malformed_date_param_is_not_a_server_error
    with_current_site(site) do
      with_rack_attack do
        with_rescued_exceptions do
          get "/agendas?date=1&date%5Bx%5D=2", headers: public_client_headers
        end

        assert_response :bad_request
      end
    end
  end

  def test_out_of_window_dates_are_throttled_without_blocking_normal_browsing
    with_current_site(site) do
      with_rack_attack("RACK_ATTACK_AGENDAS_BOGUS_DATE_LIMIT" => "2") do
        3.times do |index|
          get "/agendas", params: { start_date: "19#{index}0-01-01" }, headers: public_client_headers
        end
        assert_response :too_many_requests

        get "/agendas.json", headers: public_client_headers
        assert_response :success
      end
    end
  end

  def test_throttled_html_response_carries_retry_after
    with_current_site(site) do
      with_rack_attack("RACK_ATTACK_AGENDAS_LIMIT" => "1") do
        get "/agendas.json", headers: public_client_headers
        get "/agendas", headers: public_client_headers

        assert_response :too_many_requests
        assert_equal "text/html; charset=utf-8", response.headers["Content-Type"]
        assert_equal "no-store", response.headers["Cache-Control"]
        assert response.headers["Retry-After"].to_i.positive?
      end
    end
  end

  def test_throttled_response_is_translated_under_a_locale_prefix
    with_current_site(site) do
      with_rack_attack("RACK_ATTACK_AGENDAS_LIMIT" => "1") do
        get "/en/agendas.json", headers: public_client_headers
        get "/en/agendas", headers: public_client_headers

        assert_response :too_many_requests
        assert_includes response.body, "Too many requests"
        assert_equal "en", response.headers["Content-Language"]
      end
    end
  end

  def test_throttled_json_request_gets_a_json_body
    with_current_site(site) do
      with_rack_attack("RACK_ATTACK_AGENDAS_LIMIT" => "1") do
        2.times { get "/agendas.json", headers: public_client_headers }

        assert_response :too_many_requests
        assert_equal "application/json; charset=utf-8", response.headers["Content-Type"]
        assert JSON.parse(response.body).dig("error", "retry_after").to_i.positive?
      end
    end
  end

  def test_private_client_ips_are_not_throttled
    with_current_site(site) do
      with_rack_attack("RACK_ATTACK_AGENDAS_LIMIT" => "1") do
        3.times { get "/agendas.json", headers: { "REMOTE_ADDR" => "172.17.0.1" } }

        assert_response :success
      end
    end
  end

  def test_configured_ip_allowlist_is_not_throttled
    with_current_site(site) do
      with_rack_attack("RACK_ATTACK_AGENDAS_LIMIT" => "1", "RACK_ATTACK_SAFELIST_IPS" => "203.0.113.0/24") do
        3.times { get "/agendas.json", headers: public_client_headers }

        assert_response :success
      end
    end
  end

  def test_negative_year_budget_execution_paths_are_blocked
    with_current_site(site) do
      with_rack_attack do
        get "/presupuestos/ejecucion/-2020", headers: public_client_headers

        assert_response :forbidden
        assert_equal "text/html; charset=utf-8", response.headers["Content-Type"]
      end
    end
  end

  def test_budgets_execution_is_throttled_by_its_own_rule
    with_current_site(site) do
      with_rack_attack("RACK_ATTACK_BUDGETS_EXECUTION_LIMIT" => "1") do
        2.times { get "/presupuestos/ejecucion", headers: public_client_headers }

        assert_response :too_many_requests
      end
    end
  end
end
