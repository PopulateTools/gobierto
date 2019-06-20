# frozen_string_literal: true

require "test_helper"
require "factories/budget_line_factory"

module GobiertoBudgets
  module Api
    class BudgetLineTest < ActionDispatch::IntegrationTest

      def budget_line_id
        "28079/2019/1/G"
      end

      def amount
        BudgetLineFactory.default_amount
      end

      def request_path
        gobierto_budgets_api_budget_line_path(
          area: GobiertoBudgets::EconomicArea.area_name,
          id: budget_line_id
        )
      end

      def response_body
        JSON.parse(response.body)
      end

      def test_ok
        with factory: BudgetLineFactory.new(year: 2019) do
          get request_path

          expected_result = {
            "id" => budget_line_id,
            "area" => "economic",
            "forecast" => { "original_amount" => amount, "updated_amount" => amount },
            "execution" => { "amount" => amount }
          }

          assert_equal expected_result, response_body
        end
      end

      def test_not_found
        get request_path

        assert_equal({ "error" => "not-found" }, response_body)
      end

    end
  end
end
