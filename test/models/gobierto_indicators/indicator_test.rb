# frozen_string_literal: true

require "test_helper"

module GobiertoIndicator
  class IndicatorTest < ActiveSupport::TestCase
    def indicator
      @indicator ||= gobierto_indicators_indicators(:ita14)
    end

    def test_valid
      assert indicator.valid?
    end
  end
end
