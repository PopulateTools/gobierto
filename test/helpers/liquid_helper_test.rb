# frozen_string_literal: true

require "test_helper"

class LiquidHelperTest < ActionView::TestCase

  include LiquidHelper

  def current_site
    @current_site ||= sites(:madrid)
  end

  def test_rener_liquid
    assert_equal "Wadus", render_liquid("Wadus")
    assert_equal "", render_liquid(nil)
  end

end
