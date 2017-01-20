require "test_helper"

module GobiertoCommon
  class ContentBlockFieldTest < ActiveSupport::TestCase
    def content_block_field
      @content_block_field ||= gobierto_common_content_block_fields(:contact_method_service_name)
    end

    def test_valid
      assert content_block_field.valid?
    end

    def test_label
      assert_equal "Service", content_block_field.label["en"]
      assert_equal "Servicio", content_block_field.label["es"]
    end

    def test_localized_label
      assert_equal "Service", content_block_field.localized_label
    end
  end
end
