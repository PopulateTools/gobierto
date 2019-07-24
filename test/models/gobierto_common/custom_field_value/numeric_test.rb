# frozen_string_literal: true

require "test_helper"

module GobiertoCommon::CustomFieldValue
  class NumericTest < ActiveSupport::TestCase

    def record
      gobierto_common_custom_field_records(:neil_custom_field_record_weight)
    end

    def test_value
      assert_equal 72.3, record.value
    end

    def test_value_assign
      record.value = 66.6
      record.save

      record.reload

      assert_equal 66.6, record.value
    end

    def test_value_assign_numeric_string
      record.value = "66.6"
      record.save

      record.reload

      assert_equal 66.6, record.value
    end

    def test_value_assign_not_numeric_string
      record.value = "wadus"
      record.save

      record.reload

      assert_equal 0.0, record.value
    end

  end
end
