# frozen_string_literal: true

require "test_helper"

class SectionItemTest < ActiveSupport::TestCase
  def section_item
    @section_item ||= gobierto_cms_section_items(:participation_items)
  end

  def test_valid
    assert section_item.valid?
  end
end
