# frozen_string_literal: true

require "test_helper"
require "factories/budget_line_factory"

module GobiertoBudgets
  module Api
    class BudgetLineTest < ActionDispatch::IntegrationTest

      def site
        @site ||= sites(:huesca)
      end

      def budget_line_id
        "28079/#{Date.today.year}/1/G"
      end

      def amount
        BudgetLineFactory.default_amount
      end

      def request_path(budget_line_id_param = budget_line_id)
        gobierto_budgets_api_budget_line_path(
          area: GobiertoBudgets::EconomicArea.area_name,
          id: budget_line_id_param
        )
      end

      def response_body
        JSON.parse(response.body)
      end

      def budget_line_factory
        BudgetLineFactory.new(year: Date.today.year, organization_id: site.organization_id)
      end

      def setup
        super
        site.active!
      end

      def test_ok
        with site: site, factory: budget_line_factory do
          get request_path

          expected_result = {
            "id" => budget_line_id + "/economic",
            "area" => "economic",
            "forecast" => { "original_amount" => amount, "updated_amount" => amount },
            "execution" => { "amount" => amount }
          }

          assert_equal expected_result, response_body
        end
      end

      def test_not_found
        with(site: site) { get request_path("wadus") }

        assert_equal({ "error" => "not-found" }, response_body)
      end

    end
  end
end
