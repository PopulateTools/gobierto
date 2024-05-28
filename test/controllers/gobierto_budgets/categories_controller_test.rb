# frozen_string_literal: true

require "test_helper"

class GobiertoBudgets::Api::CategoriesControllerTest < GobiertoControllerTest
  def site
    @site ||= sites(:madrid)
  end

  def test_index_json_all_areas
    with_current_site(site) do
      get gobierto_budgets_api_categories_path, as: :json
      assert_response :success
      response_data = JSON.parse(response.body)
      assert_equal "Impuestos directos", response_data["economic"]["I"]["1"]
      assert_equal "Impuesto sobre la Renta", response_data["economic"]["I"]["10"]
      assert_equal "Gastos de personal", response_data["economic"]["G"]["1"]
      assert_equal "Deuda pública", response_data["functional"]["G"]["0"]
    end
  end

  def test_index_json_specific_area
    with_current_site(site) do
      get gobierto_budgets_api_categories_path, as: :json, params: { area: "economic", kind: "G" }
      assert_response :success
      response_data = JSON.parse(response.body)
      assert_equal "Gastos de personal", response_data["1"]
      assert_nil response_data["economic"]
      assert_nil response_data["functional"]
    end
  end

  def test_index_json_with_data
    with_current_site(site) do
      get gobierto_budgets_api_categories_path, as: :json, params: { with_data: Date.today.year - 4 }
      assert_response :success
      response_data = JSON.parse(response.body)
      assert_equal "Gastos de personal", response_data["economic"]["G"]["1"]
      assert_nil response_data["economic"]["I"]["10"]

      get gobierto_budgets_api_categories_path, as: :json, params: { with_data: Date.today.year - 2 }
      assert_response :success
      response_data = JSON.parse(response.body)
      assert_equal "Gastos de personal", response_data["economic"]["G"]["1"]
      assert_not_nil response_data["economic"]["I"]["10"]
    end
  end
end
