# frozen_string_literal: true

require "test_helper"

class SidekiqWebTest < ActionDispatch::IntegrationTest

  def secrets
    Rails.application.secrets
  end

  def sidekiq_monitor_stats_path
    "#{sidekiq_console_path}/monitor-stats"
  end

  def auth_headers
    @auth_headers ||= {
      "Authorization" => "Basic #{Base64.encode64('sidekiq_web_usr:sidekiq_web_pwd')}"
    }
  end

  def setup
    super
    secrets.stubs(:sidekiq_web_usr).returns("sidekiq_web_usr")
    secrets.stubs(:sidekiq_web_pwd).returns("sidekiq_web_pwd")
  end

  def test_visit_sidekiq_console
    get sidekiq_console_path

    assert_response 401

    get sidekiq_console_path, headers: auth_headers

    assert_response :success
  end

  def test_visit_sidekiq_monitor_stats
    get sidekiq_monitor_stats_path

    assert_response 401

    get sidekiq_monitor_stats_path, headers: auth_headers

    response_body = JSON.parse(response.body)

    assert_response :success
    assert response_body.has_key?("queues")
    assert response_body.has_key?("processes")
  end

end