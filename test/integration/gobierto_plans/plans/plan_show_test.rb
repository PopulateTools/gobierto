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

    def axes
      @axes ||= plan.categories.where(level: 0)
    end

    def action_lines
      @action_lines ||= plan.categories.where(level: 1)
    end

    def actions
      @actions ||= plan.categories.where(level: 2)
    end

    def test_indicator
      with_javascript do
        with_current_site(site) do
          visit @path
          assert has_content? "FOLLOW THE EVOLUTION OF THE GOVERNMENT PLAN"
          assert has_content? "Latest update: November 01, 2016"
        end
      end
    end
  end
end
