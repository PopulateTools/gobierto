# frozen_string_literal: true

require "test_helper"

module GobiertoCitizensCharters
  class EditionTest < ActiveSupport::TestCase
    def edition
      @edition ||= gobierto_citizens_charters_editions(:call_center_service_level_2018)
    end

    def edition_with_values
      @edition_with_values ||= gobierto_citizens_charters_editions(:call_center_service_level_2015)
    end

    def edition_with_percentage
      @edition_with_percentage ||= gobierto_citizens_charters_editions(:call_center_service_level_2014)
    end

    def test_valid
      assert edition.valid?
    end

    def test_period_date
      assert_equal "2018", edition.to_s
      assert_equal "2018-01-01 00:00:00 UTC", edition.period_start.to_s
      assert_equal "2018-12-31 23:59:59 UTC", edition.period_end.to_s

      edition.quarter!
      assert_equal "2018-3", edition.to_s
      assert_equal "2018-07-01 00:00:00 UTC", edition.period_start.to_s
      assert_equal "2018-09-30 23:59:59 UTC", edition.period_end.to_s

      edition.month!
      assert_equal "2018-9", edition.to_s
      assert_equal "2018-09-01 00:00:00 UTC", edition.period_start.to_s
      assert_equal "2018-09-30 23:59:59 UTC", edition.period_end.to_s

      edition.week!
      assert_equal "2018-37", edition.to_s
      assert_equal "2018-09-10 00:00:00 UTC", edition.period_start.to_s
      assert_equal "2018-09-16 23:59:59 UTC", edition.period_end.to_s
    end

    def test_proportion
      assert_equal 0.999, edition_with_percentage.proportion
      assert_equal 111, edition_with_values.proportion
      assert_nil edition.proportion
    end
  end
end
