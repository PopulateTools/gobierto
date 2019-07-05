# frozen_string_literal: true

require "test_helper"

module GobiertoCommon::CustomFieldValue
  class MarkdownTextTest < ActiveSupport::TestCase

    def record
      gobierto_common_custom_field_records(:neil_custom_field_record_bio)
    end

    def test_value
      assert_equal "<p><strong>Neil</strong> has a long bio</p>\n", record.value
    end

  end
end
