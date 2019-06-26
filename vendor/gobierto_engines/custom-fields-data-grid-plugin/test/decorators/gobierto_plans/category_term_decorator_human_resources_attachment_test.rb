# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class CategoryTermDecoratorHumanResourcesAttachmentTest < ActiveSupport::TestCase

    def decorator
      GobiertoPlans::CategoryTermDecorator.new(
        gobierto_common_terms(:center_basic_needs_plan_term)
      )
    end

    def plugin_data
      decorator.nodes_data.first[:attributes][:plugins_data][:human_resources]
    end

    def test_plugin_data
      assert_equal "Human Resources", plugin_data[:title_translations][:en]

      assert_equal 26_667, plugin_data[:budgeted_amount]
      assert_equal 267, plugin_data[:executed_amount]
      assert_equal "1 %", plugin_data[:executed_percentage]
    end

  end
end
