# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class ActivitiesTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = admin_activities_path
    end

    def admin
      @admin ||= gobierto_admin_admins(:tony)
    end

    def test_view_activities
      with_signed_in_admin(admin) do
        visit @path

        assert has_content?("Site updated")
        assert has_content?("Ayuntamiento de Madrid")
        assert has_content?("Tony Stark")
        assert has_content?("1.2.3.4")
      end
    end
  end
end
