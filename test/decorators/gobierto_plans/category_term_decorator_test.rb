# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class CategoryTermDecoratorTest < ActiveSupport::TestCase
    def plan
      @plan ||= gobierto_plans_plans(:strategic_plan)
    end

    def axe
      @axe ||= GobiertoPlans::CategoryTermDecorator.new(gobierto_common_terms(:people_and_families_plan_term))
    end

    def action_line
      @action_line ||= GobiertoPlans::CategoryTermDecorator.new(gobierto_common_terms(:welfare_payments_plan_term))
    end

    def actions
      @actions ||= CollectionDecorator.new(plan.categories.where(level: 2), decorator: GobiertoPlans::CategoryTermDecorator)
    end

    def action
      @action ||= GobiertoPlans::CategoryTermDecorator.new(gobierto_common_terms(:center_basic_needs_plan_term))
    end

    def projects
      node_ids = GobiertoPlans::CategoriesNode.where(category_id: actions.pluck(:id)).pluck(:node_id)
      @projects ||= GobiertoPlans::Node.where(id: node_ids)
    end

    def test_uid
      assert_equal "0", axe.uid
      assert_equal axe.level, axe.uid.split(".").size - 1

      assert_equal "0.0", action_line.uid
      assert_equal action_line.level, action_line.uid.split(".").size - 1

      assert_equal "0.0.1", action.uid
      assert_equal action.level, action.uid.split(".").size - 1
    end

    def test_children_progress
      assert_equal 25, action_line.progress
      assert_equal action_line.progress, projects.sum(:progress) / projects.size

      assert_equal 50, action.progress
    end

    def test_includes_custom_fields
      decorator = GobiertoPlans::CategoryTermDecorator.new(
        gobierto_common_terms(:center_basic_needs_plan_term)
      )
      node_attributes = decorator.nodes_data.first[:attributes]

      assert_equal 7, node_attributes[:custom_field_records].size
    end

  end
end
