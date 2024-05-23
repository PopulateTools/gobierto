# frozen_string_literal: true

require "test_helper"

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
end
