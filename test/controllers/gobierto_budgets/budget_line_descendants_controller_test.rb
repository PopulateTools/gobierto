# frozen_string_literal: true

require "test_helper"
require "factories/budget_line_factory"

class GobiertoBudgets::BudgetLineDescendantsControllerTest < GobiertoControllerTest
  def site
    @site ||= sites(:madrid)
  end

  def year
    @year ||= Date.today.year - 2
  end

  def test_index_json
    with_current_site(site) do
      get gobierto_budgets_budget_line_descendants_path(year: year, kind: GobiertoBudgets::BudgetLine::INCOME, area_name: GobiertoBudgets::EconomicArea.area_name, parent_code: '1'), as: :json
      assert_response :success
      response_data = JSON.parse(response.body)
      assert_equal 1, response_data.length
      assert_equal "Impuesto sobre la Renta", response_data.first["name"]
    end
  end

  def test_index_js
    with_current_site(site) do
      get gobierto_budgets_budget_line_descendants_path(year: year, kind: GobiertoBudgets::BudgetLine::INCOME, area_name: GobiertoBudgets::EconomicArea.area_name, parent_code: '2'), xhr: true#  as: :js
      assert_response :success
      assert_equal 1, response.body.scan(/(?=Impuesto sobre el Valor Añadido)/).count
    end
  end

  def test_index_html_responds_not_found_without_queries
    GobiertoBudgets::SearchEngine.expects(:client).never

    with_current_site(site) do
      get gobierto_budgets_budget_line_descendants_path(year: year, kind: GobiertoBudgets::BudgetLine::INCOME, area_name: GobiertoBudgets::EconomicArea.area_name, parent_code: "1")
      assert_response :not_found
    end
  end

  def test_index_js_loads_the_descendants_with_one_query_per_level
    descendants_year = 2001
    factories = [
      { code: "1" },
      { code: "11", parent_code: "1" },
      { code: "12", parent_code: "1" },
      { code: "111", parent_code: "11" },
      { code: "112", parent_code: "11" },
      { code: "121", parent_code: "12" },
      { code: "111-01", parent_code: "111" }
    ].map { |attributes| BudgetLineFactory.new(attributes.merge(year: descendants_year, indexes: [:forecast])) }
    search_spy = Spy.on(GobiertoBudgets::SearchEngine.client, :search).and_call_through

    with_current_site(site) do
      get gobierto_budgets_budget_line_descendants_path(
        year: descendants_year,
        kind: GobiertoBudgets::BudgetLine::EXPENSE,
        area_name: GobiertoBudgets::EconomicArea.area_name,
        parent_code: "1"
      ), xhr: true
      assert_response :success
    end

    %w(11 12 111 112 121 111-01).each do |code|
      assert_includes response.body, "data-budget-line=\\\"#{code}\\\""
    end
    assert_operator search_spy.calls.count, :<=, 4
  ensure
    search_spy&.unhook
    factories&.each(&:teardown)
  end
end
