# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class EmptyPlansShowTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_plans_root_path
    end

    def site
      @site ||= sites(:santander)
    end

    def test_visit_empty_plans
      with_current_site(site) do
        visit @path

        assert_equal 404, page.status_code
      end
    end
  end
end
