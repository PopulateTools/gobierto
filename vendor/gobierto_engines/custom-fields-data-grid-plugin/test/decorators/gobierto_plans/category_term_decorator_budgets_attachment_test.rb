# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class CategoryTermDecoratorBudgetsAttachmentTest < ActiveSupport::TestCase

    def decorator
      GobiertoPlans::CategoryTermDecorator.new(
        gobierto_common_terms(:center_basic_needs_plan_term)
      )
    end

    def plugin_data
      decorator.nodes_data.first[:attributes][:plugins_data][:budgets]
    end

    def test_plugin_data
      assert_equal "Budget", plugin_data[:title_translations][:en]

      assert_equal "http://madrid.gobierto.test/presupuestos", plugin_data[:detail][:link]
      assert_equal "see detail in Budgets", plugin_data[:detail][:text]

      assert_equal Float, plugin_data[:budgeted_amount].class
      assert_equal Float, plugin_data[:executed_amount].class
      assert_equal "90 %", plugin_data[:executed_percentage]
    end

  end
end
