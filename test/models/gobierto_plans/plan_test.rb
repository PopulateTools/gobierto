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

    def test_to_s
      plan_string = plan.to_s

      assert plan_string.include? "3 axes"
      assert plan_string.include? "1 line of action"
      assert plan_string.include? "2 actions"
      assert plan_string.include? "2 projects/actions"
    end

    def test_plan_without_configuration_to_s
      plan.update_attribute(:configuration_data, nil)

      plan_string = plan.to_s

      assert plan_string.include? "3 items of level 1"
      assert plan_string.include? "1 item of level 2"
      assert plan_string.include? "2 items of level 3"
      assert plan_string.include? "2 projects"
    end
  end
end
