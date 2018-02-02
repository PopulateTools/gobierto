# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class PlanShowTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_plans_plan_path(plan.slug)
    end

    def site
      @site ||= sites(:madrid)
    end

    def plan
      @plan ||= gobierto_plans_plans(:strategic_plan)
    end

    def axes
      @axes ||= plan.categories.where(level: 0)
    end

    def action_lines
      @action_lines ||= plan.categories.where(level: 1)
    end

    def actions
      @actions ||= plan.categories.where(level: 2)
    end

    def projects
      @projects ||= plan.categories.where(level: 3)
    end

    def test_indicator
      with_javascript do
        with_current_site(site) do
          visit @path

          # TODO: Pending fix test and fixtures
          #assert has_content? "Follow the evolution of the government plan"
          # assert has_content? "#{axes.size} eixos"
          # assert has_content? "#{action_lines.size} línies d'actuació"
          # assert has_content? "#{actions.size} actuacions"
          # assert has_content? "#{projects.size} projectes"
          #
          # within ".planification-content" do
          #   axes.each do |axe|
          #     assert has_content? axe.name
          #   end
          # end
        end
      end
    end
  end
end
