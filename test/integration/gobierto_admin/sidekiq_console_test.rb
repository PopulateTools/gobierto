# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class SidekiqConsoleTest < ActionDispatch::IntegrationTest

    def regular_admin
      @regular_admin ||= gobierto_admin_admins(:tony)
    end

    def god_admin
      @god_admin ||= gobierto_admin_admins(:natasha)
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_visit_sidekiq_console_as_god_admin
      with_signed_in_admin(god_admin) do
        visit sidekiq_console_path

        assert has_content?("Dashboard")
      end
    end

    def test_visit_sidekiq_console_as_regular_admin
      with_signed_in_admin(regular_admin) do
        assert_raise ActionController::RoutingError do
          visit sidekiq_console_path
        end
      end
    end

    def test_visit_sidekiq_console_as_annonymous
      assert_raise ActionController::RoutingError do
        visit sidekiq_console_path
      end
    end

  end
end
