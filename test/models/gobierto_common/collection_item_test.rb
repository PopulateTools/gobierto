require "test_helper"

module GobiertoCommon
  class CollectionItemTest < ActiveSupport::TestCase

    def collection_item
      @collection_item ||= gobierto_common_collection_items(:consultation_faq_on_site)
    end

    def test_valid
      assert collection_item.valid?
    end

  end
end
