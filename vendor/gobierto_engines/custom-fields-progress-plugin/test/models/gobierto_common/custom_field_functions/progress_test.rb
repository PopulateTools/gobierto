# frozen_string_literal: true

require "test_helper"

module GobiertoCommon::CustomFieldFunctions
  class ProgressTest < ActiveSupport::TestCase

    attr_accessor :item, :progress_record, :source_calculations_record

    def setup
      super

      @item = gobierto_plans_nodes(:political_agendas)
      @item.paper_trail.save_with_version
      @item.update_attribute(:ends_at, 2.days.from_now)
      @item.update_attribute(:ends_at, 3.days.from_now)

      @progress_record = gobierto_common_custom_field_records(:political_agendas_progress_custom_field_record)
      @source_calculations_record = gobierto_common_custom_field_records(:political_agendas_human_resources_table_custom_field_record)
      @source_calculations_record.paper_trail.save_with_version
      @source_calculations_record.update(
        payload:
        {
          human_resources_table: [
            {
              human_resource: ActiveRecord::FixtureSet.identify(:human_resources_supervisor),
              cost: 35_000,
              start_date: 1.day.ago.to_date.to_s,
              end_date: 1.day.from_now.to_date.to_s
            },
            {
              human_resource: ActiveRecord::FixtureSet.identify(:human_resources_employee),
              cost: 25_000,
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
        },
        item_has_versions: true
      )
      @source_calculations_record.update(
        payload:
        {
          human_resources_table: [
            {
              human_resource: ActiveRecord::FixtureSet.identify(:human_resources_supervisor),
              cost: 35_000,
              start_date: 1.day.ago.to_date.to_s,
              end_date: 3.days.from_now.to_date.to_s
            }
          ]
        },
        item_has_versions: true
      )
    end

    def plan
      @plan = gobierto_plans_plans :strategic_plan
    end

    def progress_custom_field
      @progress_custom_field ||= progress_record.custom_field
    end

    def test_progress
      assert_equal 0.25, progress_record.functions.progress
    end

    def test_versions_progress
      assert_equal 1.0, progress_record.functions(version: 1).progress
      assert_equal 0.5, progress_record.functions(version: 2).progress
      assert_equal 0.25, progress_record.functions(version: 3).progress
    end

    def test_progress_defined_for_instance
      progress_record.custom_field.update_attribute(:instance, plan)

      assert_equal 0.25, progress_record.functions.progress
    end

    def test_progress_refered_to_not_existing_custom_field
      progress_custom_field.update_attribute(:options, "configuration" => { "plugin_type" => "progress", "plugin_configuration" => { "custom_field_uids" => %w(wadus) } })

      assert_nil progress_record.functions.progress
    end

    def test_progress_refered_to_custom_field_not_providing_progress_function
      progress_custom_field.update_attribute(:options, "configuration" => { "plugin_type" => "progress", "plugin_configuration" => { "custom_field_uids" => %w(goals) } })

      assert_nil progress_record.functions.progress
    end

    def test_update_progress!
      progress_record.functions.update_progress!

      item.reload
      assert_equal 25.0, item.progress
    end
  end
end
