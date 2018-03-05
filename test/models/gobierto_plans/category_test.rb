# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class CategoryTest < ActiveSupport::TestCase
    def plan
      @plan ||= gobierto_plans_plans(:strategic_plan)
    end

    def axe
      @axe ||= gobierto_plans_categories(:people_and_families)
    end

    def action_line
      @action_line ||= gobierto_plans_categories(:welfare_payments)
    end

    def actions
      @actions ||= plan.categories.where(level: 2)
    end

    def action
      @action ||= gobierto_plans_categories(:center_basic_needs)
    end

    def projects
      node_ids = GobiertoPlans::CategoriesNode.where(category_id: actions.pluck(:id)).pluck(:node_id)
      @projects ||= GobiertoPlans::Node.where(id: node_ids)
    end

    def test_valid
      assert action.valid?
    end

    def test_descendants
      assert_equal 3, axe.descendants.size
      assert_equal 2, action_line.descendants.size
      assert_equal 0, action.descendants.size
    end

    def test_uid
      assert_equal axe.calculate_uid, axe.uid
      assert_equal axe.level, axe.uid.split(".").size - 1

      assert_equal action_line.calculate_uid, action_line.uid
      assert_equal action_line.level, action_line.uid.split(".").size - 1

      assert_equal action.calculate_uid, action.uid
      assert_equal action.level, action.uid.split(".").size - 1
    end

    def test_children_progress
      assert_equal action_line.progress, action_line.children_progress
      assert_equal action_line.children_progress, projects.sum(:progress) / projects.size

      assert_equal action.progress, action.children_progress
    end
  end
end
