# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class PlanTest < ActiveSupport::TestCase
    def plan
      @plan ||= gobierto_plans_plans(:strategic_plan)
    end

    def test_valid
      assert plan.valid?
    end
  end
end
