# frozen_string_literal: true

require "test_helper"

class GobiertoPlans::PlanTreeTest < ActiveSupport::TestCase
  def site
    @site ||= sites(:madrid)
  end

  def plan
    @plan ||= gobierto_plans_plans(:strategic_plan)
  end

  def test_call
    assert GobiertoPlans::PlanTree.new(plan).call
  end
end
