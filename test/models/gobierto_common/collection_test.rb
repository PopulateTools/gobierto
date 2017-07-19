require "test_helper"
require "support/concerns/gobierto_attachments/attachable_test"

module GobiertoCommon
  class CollectionTest < ActiveSupport::TestCase

    def collection
      @collection ||= gobierto_common_collections(:news)
    end

    def test_valid
      assert collection.valid?
    end
  end
end
