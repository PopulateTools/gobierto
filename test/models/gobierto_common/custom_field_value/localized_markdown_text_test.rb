# frozen_string_literal: true

require "test_helper"

module GobiertoCommon::CustomFieldValue
  class LocalizedMarkdownTextTest < ActiveSupport::TestCase

    def record
      gobierto_common_custom_field_records(:neil_custom_field_record_localized_bio)
    end

    def blank_record
      gobierto_common_custom_field_records(:juana_custom_field_record_blank_localized_bio)
    end

    def test_value
      assert_equal "<p><strong>Neil</strong> has a long bio</p>\n", record.value
    end

    def test_value_with_blank_payload
      assert_equal "", blank_record.value

      blank_record.update_attribute(:payload, nil)
      assert_equal "", blank_record.value
    end

  end
end
