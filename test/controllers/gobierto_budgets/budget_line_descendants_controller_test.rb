# frozen_string_literal: true

require "test_helper"

class GobiertoBudgets::BudgetLineDescendantsControllerTest < GobiertoControllerTest
  def site
    @site ||= sites(:madrid)
  end

  def test_index
    with_current_site(site) do
      get gobierto_budgets_budget_line_descendants_path(year: 2017, kind: GobiertoBudgets::BudgetLine::INCOME, area_name: GobiertoBudgets::EconomicArea.area_name, parent_code: '1'), as: :json
      assert_response :success
      response_data = JSON.parse(response.body)
      assert_equal 4, response_data.length
      assert_equal "Impuesto sobre la renta", response_data.first["name"]
    end
  end
end
