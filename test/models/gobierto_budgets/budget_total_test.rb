# frozen_string_literal: true

require "test_helper"
require "factories/total_budget_factory"

module GobiertoBudgets
  class BudgetTotalTest < ActiveSupport::TestCase

    POPULATION = 10
    YEAR = Date.today.year
    AMOUNT = 20_000

    def organization_id
      @organization_id ||= sites(:huesca).organization_id
    end

    def query_params
      { organization_id: organization_id, year: YEAR }
    end

    def factory_params
      { organization_id: organization_id, population: POPULATION, total_budget: AMOUNT }
    end

    def test_budgeted_updated_for
      f = TotalBudgetFactory.new(factory_params.merge(indexes: [:forecast_updated]))

      with(factory: f) do
        assert_equal AMOUNT, BudgetTotal.budgeted_updated_for(query_params)
      end
    end

    def test_budgeted_updated_for_when_no_data
      f = TotalBudgetFactory.new(factory_params.merge(indexes: [:forecast]))

      with(factory: f) do
        assert_nil BudgetTotal.budgeted_updated_for(query_params)
      end
    end

    def test_budget_updated_for_when_fallback_allowed
      f = TotalBudgetFactory.new(factory_params.merge(indexes: [:forecast]))

      with(factory: f) do
        result = BudgetTotal.budgeted_updated_for(query_params.merge(fallback: true))
        assert_equal AMOUNT, result
      end
    end

    def test_budgeted_for
      f = TotalBudgetFactory.new(factory_params)

      with(factory: f) do
        assert_equal AMOUNT, BudgetTotal.budgeted_for(*query_params.values)
      end
    end

    def test_budgeted_for_when_no_data
      assert_nil BudgetTotal.budgeted_for(*query_params.values)
    end

    def test_execution_for
      f = TotalBudgetFactory.new(factory_params.merge(indexes: [:executed]))

      with(factory: f) do
        assert_equal AMOUNT, BudgetTotal.execution_for(*query_params.values)
      end
    end

    def test_execution_for_when_no_data
      assert_nil BudgetTotal.execution_for(*query_params.values)
    end

    def test_for
      result = BudgetTotal.for(*query_params.values)

      assert_nil result

      with(factory: TotalBudgetFactory.new(factory_params)) do
        assert_equal AMOUNT, BudgetTotal.for(*query_params.values)
      end
    end

    def test_for_organizations
      query_params = [[organization_id], YEAR]

      assert_equal [], BudgetTotal.for_organizations(*query_params)

      with(factory: TotalBudgetFactory.new(factory_params)) do
        assert_equal 1, BudgetTotal.for_organizations(*query_params).size
      end
    end

  end
end
