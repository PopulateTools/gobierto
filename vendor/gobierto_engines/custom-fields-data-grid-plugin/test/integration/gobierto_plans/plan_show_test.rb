# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class PlanShowTest < ActionDispatch::IntegrationTest

    attr_reader :site, :path

    def setup
      super
      @site = sites(:madrid)
      plan = gobierto_plans_plans(:strategic_plan)
      @path = gobierto_plans_plan_path(slug: plan.plan_type.slug, year: plan.year)
    end

    def test_expand_plan_node
      with(site: site, js: true) do
        visit @path

        find("h3", text: "People and families").click
        find("a", text: "Provide social assistance to individuals and families who need it for lack of resources").click
        find("a", text: "Basic needs of District Center families").click
        find("td", text: "Publish political agendas").click

        assert has_content?("Long description")
        assert has_content?("In progress")
        assert has_content?("Mammal")
        assert has_content?("Raw savings")
        assert has_content?("Net savings")
        assert has_content?("Budget")
      end
    end

  end
end
