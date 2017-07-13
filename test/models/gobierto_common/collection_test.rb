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

    def test_find_by_slug
      assert_nil GobiertoCommon::Collection.find_by_slug! nil
      assert_nil GobiertoCommon::Collection.find_by_slug! ""
      assert_raises(ActiveRecord::RecordNotFound) do
        GobiertoCommon::Collection.find_by_slug! "foo"
      end

      assert_equal collection, GobiertoCommon::Collection.find_by_slug!(collection.slug_es)
      assert_equal collection, GobiertoCommon::Collection.find_by_slug!(collection.slug_en)
    end
  end
end
