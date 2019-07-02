# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class NodeTest < ActiveSupport::TestCase

    def setup
      super
      @node = gobierto_plans_nodes(:scholarships_in_school_cateens)
      @plan = gobierto_plans_plans(:economic_plan)

      @global_custom_field = gobierto_common_custom_fields(:madrid_node_global)
      @global_custom_field_record = gobierto_common_custom_field_records(:scholarships_in_school_cateens_custom_field_global_level)

      @instance_custom_field = gobierto_common_custom_fields(:madrid_economic_plan_node_instance_level)
      @instance_custom_field_record = gobierto_common_custom_field_records(:scholarships_in_school_cateens_custom_field_instance_level)
    end

    def node_custom_field_records
      ::GobiertoPlans::Node.node_custom_field_records(@plan, @node)
    end

    def test_valid
      assert @node.valid?
    end

    def test_custom_field_records
      ::GobiertoCommon::CustomFieldRecord.destroy_all
      ::GobiertoCommon::CustomField.destroy_all

      # when empty
      assert node_custom_field_records.empty?

      # when only global records
      ::GobiertoCommon::CustomField.create!(@global_custom_field.attributes)
      record = ::GobiertoCommon::CustomFieldRecord.create!(@global_custom_field_record.attributes)

      assert_equal [record], node_custom_field_records

      # when global and instance-level records
      ::GobiertoCommon::CustomField.create!(@instance_custom_field.attributes)
      record = ::GobiertoCommon::CustomFieldRecord.create!(@instance_custom_field_record.attributes)

      assert_equal [record], node_custom_field_records
    end

  end
end
