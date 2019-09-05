# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class ActivitiesTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = admin_activities_path
    end

    def manager_admin
      @manager_admin ||= gobierto_admin_admins(:nick)
    end

    def regular_admin
      @regular_admin ||= gobierto_admin_admins(:steve)
    end

    def test_regular_view_activities
      with_signed_in_admin(regular_admin) do
        visit @path

        assert has_alert?("You are not authorized to perform this action")
        assert has_no_content?("Activity log")
        assert has_no_content?("Site updated")
        assert has_no_content?("1.2.3.4")
        assert_equal edit_admin_admin_settings_path, current_path
      end
    end

    def test_manager_view_activities
      with_signed_in_admin(manager_admin) do
        visit @path

        assert has_content?("Activity log")
        assert has_content?("Site updated")
        assert has_content?("Ayuntamiento de Madrid")
        assert has_content?("Tony Stark")
        assert has_content?("1.2.3.4")
      end
    end
  end
end
