require "test_helper"

class GobiertoBudgets::BudgetLineTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = gobierto_budgets_budget_line_path('1', last_year, GobiertoBudgets::EconomicArea.area_name, GobiertoBudgets::BudgetLine::EXPENSE)
  end

  def site
    @site ||= sites(:madrid)
  end

  def last_year
    2016
  end

  def test_budget_line_information
    with_current_site(site) do
      visit @path

      assert has_content?("Gastos de personal")
      assert has_content?("Órganos de gobierno y personal directivo")
    end
  end

  def test_metric_boxes
    with_current_site(site) do
      visit @path

      assert has_css?(".metric_box h3", text: "Expense plan. / inh.")
      assert has_css?(".metric_box h3", text: "Expense planned")
      assert has_css?(".metric_box h3", text: "Expense real vs. plan.")
      assert has_css?(".metric_box h3", text: "% over the total")
      assert has_css?(".metric_box h3", text: "Avg. expense in the province")
      assert page.all(".metric_box .metric").all?{ |e| e.text =~ /\d{2}/}
    end
  end

  def test_invalid_budget_line_url
    with_current_site(site) do
      visit gobierto_budgets_budget_line_path('1', last_year, GobiertoBudgets::EconomicArea.area_name, 'foo')

      assert_equal 400, status_code
    end
  end
end
