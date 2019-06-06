# frozen_string_literal: true

require "test_helper"

class GobiertoPlans::PlanTreeTest < ActiveSupport::TestCase
  def site
    @site ||= sites(:madrid)
  end

  def plan
    @plan ||= gobierto_plans_plans(:strategic_plan)
  end

  def service_call
    @service_call ||= plan_service.call(true)
  end

  def plan_service
    @plan_service ||= GobiertoPlans::PlanTree.new(plan)
  end

  def published_project
    @published_project ||= gobierto_plans_nodes(:political_agendas)
  end

  def draft_project
    @draft_project ||= gobierto_plans_nodes(:scholarships_kindergartens)
  end

  def plan_tree_json
    @plan_tree_json ||= File.read(Rails.root.join("test/fixtures/gobierto_plans/plan_tree.json")).strip
  end

  def test_call
    assert_equal plan_tree_json, service_call.to_json
  end

  def test_not_published_projects_are_not_included
    assert_match(/#{published_project.name}/, service_call.to_json)
    assert_no_match(/#{draft_project.name}/, service_call.to_json)
  end
end
