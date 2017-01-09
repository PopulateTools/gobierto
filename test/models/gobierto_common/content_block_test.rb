require "test_helper"

module GobiertoCommon
  class ContentBlockTest < ActiveSupport::TestCase
    def content_block
      @content_block ||= gobierto_common_content_blocks(:contact_methods)
    end

    def test_valid
      assert content_block.valid?
    end

    def test_title
      assert_equal "Contact methods", content_block.title["en"]
      assert_equal "Formas de contacto", content_block.title["es"]
    end
  end
end
