# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class PlanShowTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_plans_plan_path(plan.slug)
    end

    def site
      @site ||= sites(:madrid)
    end

    def plan
      @plan ||= gobierto_plans_plans(:strategic_plan)
    end

    def test_indicator
      with_javascript do
        with_current_site(site) do
          visit @path
          byebug
          # assert has_content? plan.title
          # assert has_content? plan.description

        end
      end
    end
  end
end
