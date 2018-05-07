# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class SidekiqMonitorStatsTest < ActionDispatch::IntegrationTest

    def sidekiq_monitor_stats_path
      "#{sidekiq_console_path}/monitor-stats"
    end

    def test_visit_stats_from_localhost
      ActionDispatch::Request.any_instance.stubs(:remote_addr).returns("127.0.0.1")

      response_code = get(sidekiq_monitor_stats_path)

      assert_equal 200, response_code
    end

    def test_visit_stats_from_external_host
      ActionDispatch::Request.any_instance.stubs(:remote_addr).returns("1.2.3.4")

      assert_raise ActionController::RoutingError do
        get(sidekiq_monitor_stats_path)
      end
    end

  end
end
