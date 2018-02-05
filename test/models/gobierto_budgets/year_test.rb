# frozen_string_literal: true

require "test_helper"

class GobiertoBudgets::SearchEngineConfiguration::YearTest < ActiveSupport::TestCase
  def site
    @site ||= sites(:madrid)
  end

  def setup
    super
    ::GobiertoCore::CurrentScope.current_site = site
  end

  def test_last_year_when_no_data
    assert_equal 2017, GobiertoBudgets::SearchEngineConfiguration::Year.last
  end

  def test_last_year_when_data_and_elaboration_enabled
    GobiertoBudgets::BudgetLine.stub(:any_data?, true) do
      site.gobierto_budgets_settings.settings["budgets_elaboration"] = true
      site.save!
      assert_equal 2017, GobiertoBudgets::SearchEngineConfiguration::Year.last
    end
  end

  def test_last_year_when_data_and_elaboration_disabled
    GobiertoBudgets::BudgetLine.stub(:any_data?, true) do
      assert_equal 2018, GobiertoBudgets::SearchEngineConfiguration::Year.last
    end
  end
end
