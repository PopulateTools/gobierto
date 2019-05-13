# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class PlanDecoratorTest < ActiveSupport::TestCase
    def plan
      @plan ||= gobierto_plans_plans(:strategic_plan)
    end

    def decorated_plan
      @decorated_plan ||= PlanDecorator.new(plan)
    end

    def test_to_s
      plan_string = decorated_plan.to_s

      assert plan_string.include? "3 axes"
      assert plan_string.include? "1 line of action"
      assert plan_string.include? "2 actions"
      assert plan_string.include? "2 projects/actions"
    end

    def test_plan_without_configuration_to_s
      plan.update_attribute(:configuration_data, nil)

      plan_string = decorated_plan.to_s

      assert plan_string.include? "3 items of level 1"
      assert plan_string.include? "1 item of level 2"
      assert plan_string.include? "2 items of level 3"
      assert plan_string.include? "2 projects"
    end

    def test_level_keys_of_plan
      assert_equal decorated_plan.level_keys, plan.configuration_data.slice("level0", "level1", "level2", "level3")
    end
  end
end
