# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class CategoryTermDecoratorBudgetsAttachmentTest < ActiveSupport::TestCase

    def decorator
      GobiertoPlans::CategoryTermDecorator.new(
        gobierto_common_terms(:center_basic_needs_plan_term)
      )
    end

    def custom_field_record
      @custom_field_record ||= gobierto_common_custom_field_records :political_agendas_budgets_custom_field_record
    end

    def project
      @project ||= gobierto_plans_nodes :political_agendas
    end

    def plugin_data
      @plugin_data ||= decorator.nodes_data.first[:attributes][:plugins_data][:budgets]
    end

    def test_plugin_data
      assert_equal "Budget", plugin_data[:title_translations][:en]

      assert_equal "http://madrid.gobierto.test/presupuestos", plugin_data[:detail][:link]
      assert_equal "see detail in Budgets", plugin_data[:detail][:text]

      assert_equal 37037.04, plugin_data[:budgeted_amount]
      assert_equal 18518.52, plugin_data[:executed_amount]
      assert_equal "50 %", plugin_data[:executed_percentage]
    end

    def test_versioned_plugin_data
      project.paper_trail.save_with_version
      project.update_attribute(:ends_at, 2.days.ago)

      custom_field_record.paper_trail.save_with_version
      custom_field_record.update(
        payload: { "budget_lines" => [] },
        item_has_versions: true
      )
      assert_equal "50 %", decorator.nodes_data.first[:attributes][:plugins_data][:budgets][:executed_percentage]

      project.update_attribute(:published_version, 2)
      assert_equal "0 %", decorator.nodes_data.first[:attributes][:plugins_data][:budgets][:executed_percentage]
    end

  end
end
