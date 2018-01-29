# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class PlanTypeTest < ActiveSupport::TestCase
    def plan_type
      @plan_type ||= gobierto_plans_plan_types(:pam)
    end

    def test_valid
      assert plan_type.valid?
    end
  end
end
