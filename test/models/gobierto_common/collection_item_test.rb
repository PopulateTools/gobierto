require "test_helper"

class GobiertoCommon::CollectionItemTest < ActiveSupport::TestCase
  def collection_item
    @collection_item ||= GobiertoCommon::CollectionItem.new
  end

  def test_valid
    assert collection_item.valid?
  end
end
