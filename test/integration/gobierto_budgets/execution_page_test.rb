# frozen_string_literal: true

require "test_helper"
require "factories/budget_line_factory"
require "factories/total_budget_factory"

class GobiertoBudgets::ExecutionPageTest < ActionDispatch::IntegrationTest
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

  def budget_execution_graph_lines
    all("a.line")
  end

  def budget_graph_filters
    all(".inline_filter button").map(&:text)
  end

  def income_summary_box
    find(".metric_box:first-of-type").text
  end

  def expenses_summary_box
    find(".metric_box:nth-of-type(2)").text
  end

  def test_execution_summary_boxes
    f1 = TotalBudgetFactory.new(year: last_year)
    f2 = TotalBudgetFactory.new(year: last_year, kind: GobiertoBudgetsData::GobiertoBudgets::INCOME)

    with(factories: [f1, f2], js: true) do
      with_current_site(placed_site) do
        visit @path

        assert has_content?("BUDGET EXECUTION")

        assert income_summary_box.include? "Planned income"
        assert income_summary_box.include? "Initial budget"
        assert income_summary_box.include? "Executed income"

        assert expenses_summary_box.include? "Planned expenses"
        assert expenses_summary_box.include? "Initial budget"
        assert expenses_summary_box.include? "Executed expenses"
      end
    end
  end

  def test_execution_graphs
    f1 = BudgetLineFactory.new(year: last_year, area: GobiertoBudgetsData::GobiertoBudgets::CUSTOM_AREA_NAME)
    f2 = BudgetLineFactory.new(year: last_year, area: GobiertoBudgetsData::GobiertoBudgets::CUSTOM_AREA_NAME, kind: GobiertoBudgetsData::GobiertoBudgets::INCOME)

    with(site: placed_site, js: true, factories: [f1, f2]) do
      visit @path

      within("#expenses-execution") do
        assert has_content?("EXPLORE THE EXECUTION OF THE EXPENSES")
        assert budget_execution_graph_lines.count.positive?
        assert budget_graph_filters.include? "CUSTOM"
      end

      within("#income-execution") do
        assert has_content?("EXPLORE THE EXECUTION OF THE INCOME")
        assert budget_execution_graph_lines.count.positive?
        assert budget_graph_filters.include? "CUSTOM"
      end
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
