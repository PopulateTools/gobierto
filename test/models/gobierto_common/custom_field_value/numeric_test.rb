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

    def test_value_assign_string_with_only_a_comma
      record.value = "1,56"
      record.save

      record.reload

      assert_equal 1.56, record.value
    end

    def test_value_assign_string_with_more_than_a_comma
      record.value = "1,000,000"
      record.save

      record.reload

      assert_equal 1000000.0, record.value
    end

    def test_value_assign_string_with_comma_and_dot
      record.value = "1,000.78"
      record.save

      record.reload

      assert_equal 1000.78, record.value
    end

    def test_value_assign_integer
      record.value = 25
      record.save

      record.reload

      assert_equal 25.0, record.value
    end

  end
end
