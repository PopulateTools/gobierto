# frozen_string_literal: true

require "test_helper"

class CensusItemTest < ActiveSupport::TestCase
  def census_item
    @census_item ||= census_items(:madrid_92)
  end

  def test_valid
    assert census_item.valid?
  end
end
