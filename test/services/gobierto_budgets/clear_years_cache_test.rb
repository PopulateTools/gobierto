# frozen_string_literal: true

require "test_helper"

module GobiertoBudgets
  class ClearYearsCacheTest < ActiveSupport::TestCase
    def site
      @site ||= sites(:madrid)
    end

    def year_class
      GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year
    end

    def setup
      super
      Rails.cache.clear
      ::GobiertoCore::CurrentScope.current_site = site
    end

    def teardown
      ::GobiertoCore::CurrentScope.current_site = nil
      super
    end

    def test_call_expires_the_cached_years
      year_class.stubs(:last_year_with_data).returns(2020)
      year_class.last
      year_class.with_data

      ClearYearsCache.new.call

      # Madrid has budgets elaboration enabled, so the last year is the previous one
      year_class.stubs(:last_year_with_data).returns(2021)
      assert_equal 2020, year_class.last
    end

    def test_call_keeps_other_cache_entries
      Rails.cache.write("other", "value")

      ClearYearsCache.new.call

      assert_equal "value", Rails.cache.read("other")
    end
  end
end
