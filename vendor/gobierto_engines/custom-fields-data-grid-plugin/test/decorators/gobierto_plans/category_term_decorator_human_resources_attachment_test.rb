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

    def project
      @project ||= gobierto_plans_nodes :political_agendas
    end

    def human_resource_record
      gobierto_common_custom_field_records(:political_agendas_human_resources_custom_field_record)
    end

    def human_resources
      [
        {
          human_resource: ActiveRecord::FixtureSet.identify(:human_resources_supervisor),
          cost: 30_000,
          start_date: 1.day.ago.to_date.to_s,
          end_date: 1.day.from_now.to_date.to_s
        },
        {
          human_resource: ActiveRecord::FixtureSet.identify(:human_resources_employee),
          cost: 20_000,
          start_date: 1.day.ago.to_date.to_s,
          end_date: 1.day.from_now.to_date.to_s
        }
      ]
    end

    def test_plugin_data
      human_resource_record.update(payload: { human_resources: human_resources })

      assert_equal "Human Resources", plugin_data[:title_translations][:en]

      assert_equal 50_000, plugin_data[:budgeted_amount]
      assert_equal 25000, plugin_data[:executed_amount]
      assert_equal "50 %", plugin_data[:executed_percentage]
    end

    def test_versioned_plugin_data
      project.paper_trail.save_with_version
      project.update_attribute(:ends_at, 2.days.ago)

      human_resource_record.paper_trail.save_with_version
      human_resource_record.update(
        payload: { human_resources: human_resources },
        item_has_versions: true
      )

      assert_equal 80_000, plugin_data[:budgeted_amount]
      assert_equal 80_000, plugin_data[:executed_amount]
      assert_equal "100 %", plugin_data[:executed_percentage]

      project.update_attribute(:published_version, 2)
      assert_equal 50_000, plugin_data[:budgeted_amount]
      assert_equal 25_000, plugin_data[:executed_amount]
      assert_equal "50 %", plugin_data[:executed_percentage]
    end

  end
end
