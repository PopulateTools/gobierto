# frozen_string_literal: true

require "test_helper"
require "factories/budget_line_factory"

module GobiertoBudgets
  module Api
    class BudgetLineTest < ActionDispatch::IntegrationTest

      def site
        @site ||= sites(:madrid)
      end

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

      def budget_line_factory
        BudgetLineFactory.new(year: 2019, site: site)
      end

      def test_ok
        with site: site, factory: budget_line_factory do
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
        with(site: site) { get request_path }

        assert_equal({ "error" => "not-found" }, response_body)
      end

      def test_when_site_is_draft
        site.draft!

        with site: site, factory: budget_line_factory do
          Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new("production"))

          get request_path
        end

        assert_equal "200", response.code
      end

    end
  end
end
