# frozen_string_literal: true

require "test_helper"

class GobiertoPlans::PlanTreeTest < ActiveSupport::TestCase
  def site
    @site ||= sites(:madrid)
  end

  def plan
    @plan ||= gobierto_plans_plans(:strategic_plan)
  end

  def plan_service
    @plan_service ||= GobiertoPlans::PlanTree.new(plan)
  end

  def plan_tree_json
    File.read(Rails.root.join("test/fixtures/gobierto_plans/plan_tree.json")).strip
  end

  def test_call
    assert_equal plan_tree_json, plan_service.call(true).to_json
  end
end
