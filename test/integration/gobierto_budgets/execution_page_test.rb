# frozen_string_literal: true

require "test_helper"

class GobiertoBudgets::ExecutionPpageTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = gobierto_budgets_budgets_execution_path(last_year)
  end

  def placed_site
    @placed_site ||= sites(:madrid)
  end

  def organization_site
    @organization_site ||= sites(:organization_wadus)
  end

  def last_year
    Date.today.year - 1
  end

  def test_execution_information
    with_each_current_site(placed_site, organization_site) do
      visit @path

      assert has_content?("Budget execution")
    end
  end

  def test_year_breadcrumb
    available_years = [2017, 2016]
    GobiertoBudgets::SearchEngineConfiguration::Year.expects(:with_data).with(
      index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed
    ).returns(available_years)

    with_current_site(placed_site) do
      visit gobierto_budgets_budgets_execution_path(available_years.first)

      within "#popup-year" do
        assert has_content? available_years.first
        assert has_content? available_years.second
        assert has_selector?("tr", count: available_years.size)
      end
    end
  end

  def test_year_breadcrumb_click
    available_years = [2017]
    GobiertoBudgets::SearchEngineConfiguration::Year.stubs(:with_data).with(
      index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed
    ).returns(available_years)

    with_current_site(placed_site) do
      visit gobierto_budgets_budgets_execution_path(available_years.first)

      all('a', text: available_years.first, visible: false).first.click

      assert_equal current_path, gobierto_budgets_budgets_execution_path(available_years.first)
    end
  end
end
