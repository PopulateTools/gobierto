# frozen_string_literal: true

require "test_helper"
require "support/populate_data_helpers"

class GobiertoPlans::PlanTreeTest < ActiveSupport::TestCase
  include PopulateDataHelpers

  def site
    @site ||= sites(:madrid)
  end

  def plan
    @plan ||= gobierto_plans_plans(:strategic_plan)
  end

  def plan_service
    @plan_service ||= begin
      GobiertoPlans::PlanTree.new(plan)
    end
  end

  def test_call
    with_stubbed_populate_data_plan do
      assert_equal [populate_data_plan], plan_service.call.to_json
    end
  end
end
