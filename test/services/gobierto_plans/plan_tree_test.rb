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
    @service_call ||= plan_service.call(true).map(&:with_indifferent_access)
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

  def second_category
    {
      id: 184_796_018,
      uid: "1",
      type: "category",
      max_level: false,
      level: 0,
      attributes: {
        title: {
          en: "Economy",
          es: "Economía"
        },
        parent_id: nil,
        progress: nil,
        img: "http://gobierto.es/assets/v2/logo-gobierto.svg",
        counter: true,
        children_count: 0,
        nodes_list_path: "/planes/gobierto_plans/api/plan_projects/28856268/184796018?locale=en"
      },
      children: []
    }.with_indifferent_access
  end

  def third_category
    {
      id: 344_799_082,
      uid: "2",
      type: "category",
      max_level: false,
      level: 0,
      attributes: {
        title: {
          en: "City",
          es: "Ciudad"
        },
        parent_id: nil,
        progress: nil,
        img: "http://gobierto.es/assets/v2/logo-gobierto.svg",
        counter: true,
        children_count: 0,
        nodes_list_path: "/planes/gobierto_plans/api/plan_projects/28856268/344799082?locale=en"
      },
      children: []
    }.with_indifferent_access
  end

  def test_response
    assert_equal 3, service_call.size

    assert_equal second_category, service_call.second
    assert_equal third_category, service_call.third
  end

  def test_not_published_projects_are_not_included
    assert_match(/#{published_project.name}/, service_call.to_json)
    assert_no_match(/#{draft_project.name}/, service_call.to_json)
  end
end
