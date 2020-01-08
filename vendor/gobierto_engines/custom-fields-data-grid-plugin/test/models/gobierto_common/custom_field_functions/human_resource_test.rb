# frozen_string_literal: true

require "test_helper"

module GobiertoCommon::CustomFieldFunctions
  class HumanResourceTest < ActiveSupport::TestCase

    attr_accessor :item, :human_resource_record, :source_calculations_record

    def setup
      super

      @item = gobierto_plans_nodes(:political_agendas)
      @item.paper_trail.save_with_version
      @item.update_attribute(:ends_at, 2.days.from_now)
      @item.update_attribute(:ends_at, 3.days.from_now)

      @human_resource_record = gobierto_common_custom_field_records(:political_agendas_human_resources_table_custom_field_record)
      @human_resource_record.paper_trail.save_with_version
      @human_resource_record.update(
        payload:
        {
          human_resources_table: [
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
            },
            {
              human_resource: ActiveRecord::FixtureSet.identify(:human_resources_employee),
              cost: 10_000,
              start_date: 1.day.ago.to_date.to_s,
              end_date: 1.day.from_now.to_date.to_s
            }
          ]
        },
        item_has_versions: true
      )
      @human_resource_record.update(
        payload:
        {
          human_resources_table: [
            {
              human_resource: ActiveRecord::FixtureSet.identify(:human_resources_supervisor),
              cost: 35_000,
              start_date: 1.day.from_now.to_date.to_s,
              end_date: 2.days.from_now.to_date.to_s
            },
            {
              human_resource: ActiveRecord::FixtureSet.identify(:human_resources_employee),
              cost: 25_000,
              start_date: 1.day.from_now.to_date.to_s,
              end_date: 2.days.from_now.to_date.to_s
            },
            {
              human_resource: ActiveRecord::FixtureSet.identify(:human_resources_employee),
              cost: 20_000,
              start_date: 1.day.from_now.to_date.to_s,
              end_date: 2.days.from_now.to_date.to_s
            }
          ]
        },
        item_has_versions: true
      )
    end

    def test_progress
      assert_equal 0.0, human_resource_record.functions.progress
    end

    def test_planned_cost
      assert_equal 80_000.0, human_resource_record.functions.planned_cost
    end

    def test_executed_cost
      assert_equal 0.0, human_resource_record.functions.executed_cost
    end

    def test_versions_planned_cost
      assert_equal 80_000.0, human_resource_record.functions(version: 1).planned_cost
      assert_equal 60_000.0, human_resource_record.functions(version: 2).planned_cost
      assert_equal 80_000.0, human_resource_record.functions(version: 3).planned_cost
    end

    def test_versions_executed_cost
      assert_equal 80_000.0, human_resource_record.functions(version: 1).executed_cost
      assert_equal 30_000.0, human_resource_record.functions(version: 2).executed_cost
      assert_equal 0.0, human_resource_record.functions(version: 3).executed_cost
    end

    def test_versions_progress
      assert_equal 1.0, human_resource_record.functions(version: 1).progress
      assert_equal 0.5, human_resource_record.functions(version: 2).progress
      assert_equal 0.0, human_resource_record.functions(version: 3).progress
    end
  end
end
