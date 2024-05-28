# frozen_string_literal: true

require "test_helper"

module GobiertoBudgets
  class YearTest < ActiveSupport::TestCase

    def site
      @site ||= sites(:madrid)
    end

    def year
      @year ||= Date.today.year
    end

    def setup
      super
      ::GobiertoCore::CurrentScope.current_site = site
      Rails.cache.clear
    end

    def subject_class
      GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year
    end

    def test_last_year_when_no_data
      assert_equal year - 1, subject_class.last
    end

    def test_last_year_when_data_and_elaboration_enabled
      GobiertoBudgets::BudgetLine.stub(:any_data?, true) do
        site.gobierto_budgets_settings.settings["budgets_elaboration"] = true
        site.save!
        assert_equal year, subject_class.last
      end
    end

    def test_last_year_when_data_and_elaboration_disabled
      GobiertoBudgets::BudgetLine.stub(:any_data?, true) do
        assert_equal year, subject_class.last
      end
    end

    def test_all
      subject_class.stubs(:last).returns(2011)

      assert_equal [2011, 2010], subject_class.all
    end

    def test_with_data
      subject_class.stubs(:all).returns((2010..2012).to_a.reverse)

      args = { site: site, index: nil }

      GobiertoBudgets::BudgetLine.expects(:any_data?).with(args.merge(year: 2010)).returns(true)
      GobiertoBudgets::BudgetLine.expects(:any_data?).with(args.merge(year: 2011)).returns(false)
      GobiertoBudgets::BudgetLine.expects(:any_data?).with(args.merge(year: 2012)).returns(true)

      expected_years = [2010, 2012]

      assert array_match(expected_years, subject_class.with_data)
    end

  end
end
