# frozen_string_literal: true

require "test_helper"
require "factories/budget_line_factory"

module GobiertoBudgets
  module Api
    class AvailableYearsTest < ActionDispatch::IntegrationTest

      def site
        @site ||= sites(:madrid)
      end

      def admin
        @admin ||= gobierto_admin_admins(:natasha)
      end

      def request_path
        gobierto_budgets_api_available_years_path(organization_id: site.organization_id)
      end

      def response_body
        JSON.parse(response.body)
      end

      def setup
        budgets_settings = site.gobierto_budgets_settings
        budgets_settings.settings["budgets_elaboration"] = false
        budgets_settings.save
      end

      def with_production_draft_site(params = {})
        params[:site].draft!
        Rails.stubs(:env).returns(ActiveSupport::StringInquirer.new("production"))
        with(params) { yield }
      end

      def test_when_ok
        factories = [BudgetLineFactory.new(year: 2018), BudgetLineFactory.new(year: 2019)]

        with(site: site, factories: factories) do
          get request_path

          assert_equal [2018, 2019], response_body
        end
      end

      def test_when_empty
        with(site: site) { get request_path }

        assert response_body.empty?
      end

      def test_when_site_is_draft
        with_production_draft_site(site: site) do
          get request_path
        end

        assert_equal "200", response.code # o 401, a ver en qué quedamos
      end

      def test_when_site_is_draft_and_admin_logged_in
        with_production_draft_site(site: site, admin: admin) do
          get request_path
        end

        assert_equal "200", response.code
      end

    end
  end
end
