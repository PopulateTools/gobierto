# frozen_string_literal: true

require "test_helper"
require "factories/total_budget_factory"

module GobiertoBudgets
  class SiteStatsTest < ActiveSupport::TestCase

    SUBJECT_CLASS = GobiertoBudgets::SiteStats
    POPULATION = 10
    TOTAL_BUDGET = 20_000
    UPDATED_BUDGET_RATIO = 1.25
    UPDATED_TOTAL_BUDGET = TOTAL_BUDGET * UPDATED_BUDGET_RATIO

    def setup
      SUBJECT_CLASS.any_instance.stubs(:population).returns(POPULATION)
    end

    def site
      @site ||= sites(:huesca)
    end

    def stats
      SUBJECT_CLASS.new(site: site, year: Date.today.year)
    end

    def factory_params(params)
      {
        organization_id: site.organization_id,
        population: POPULATION,
        total_budget: params.values.first,
        indexes: params.keys.first ? [params.keys.first] : nil
      }
    end

    def total(params = {})
      TotalBudgetFactory.new(factory_params(params))
    end

    def total_income(params = {})
      TotalBudgetFactory.new(
        factory_params(params).merge(kind: GobiertoBudgetsData::GobiertoBudgets::INCOME)
      )
    end

    def test_total_budget
      # when no data
      assert_nil stats.total_budget

      # when initial estimate
      with factory: total(forecast: TOTAL_BUDGET) do
        assert_equal TOTAL_BUDGET, stats.total_budget
      end
    end

    def test_total_budget_updated
      # when no data
      assert_nil stats.total_budget_updated

      # when initial estimate
      with factory: total(forecast: TOTAL_BUDGET) do
        assert_nil stats.total_budget_updated
      end

      # when initial estimate and fallback allowed
      with factory: total(forecast: TOTAL_BUDGET) do
        assert_equal TOTAL_BUDGET, stats.total_budget_updated(fallback: true)
      end

      # when initial estimate and updated data
      f1 = total(forecast: 100)
      f2 = total(forecast_updated: 150)

      with factories: [f1, f2] do
        assert_equal 150, stats.total_budget_updated
      end
    end

    def test_total_budget_per_inhabitant_updated
      # when no data
      assert_nil stats.total_budget_per_inhabitant_updated

      # when initial estimate
      with factory: total(forecast: TOTAL_BUDGET) do
        assert_nil stats.total_budget_per_inhabitant_updated
      end

      # when initial estimate and fallback allowed
      with factory: total(forecast: TOTAL_BUDGET) do
        assert_equal(TOTAL_BUDGET / POPULATION, stats.total_budget_per_inhabitant_updated(fallback: true))
      end

      # when updated data
      f1 = total(forecast: TOTAL_BUDGET)
      f2 = total(forecast_updated: UPDATED_TOTAL_BUDGET)

      with factories: [f1, f2] do
        assert_equal(UPDATED_TOTAL_BUDGET / POPULATION, stats.total_budget_per_inhabitant_updated)
      end
    end

    def test_total_income_budget
      # when no data
      assert_nil stats.total_income_budget

      # when initial estimate
      with factory: total_income(forecast: TOTAL_BUDGET) do
        assert_equal TOTAL_BUDGET, stats.total_income_budget
      end
    end

    def test_total_income_budget_updated
      # when no data
      assert_nil stats.total_income_budget_updated

      # when initial estimate
      with factory: total_income(forecast: TOTAL_BUDGET) do
        assert_nil stats.total_income_budget_updated
      end

      # when initial estimate and fallback allowed
      with factory: total_income(forecast: TOTAL_BUDGET) do
        assert_equal TOTAL_BUDGET, stats.total_income_budget_updated(fallback: true)
      end

      # when initial estimate and updated data
      f1 = total_income(forecast: 100)
      f2 = total_income(forecast_updated: 150)

      with factories: [f1, f2] do
        assert_equal 150, stats.total_income_budget_updated
      end
    end

    def test_total_budget_executed
      # when no data
      assert_nil stats.total_budget_executed

      # when data
      with factory: total(executed: TOTAL_BUDGET) do
        assert_equal TOTAL_BUDGET, stats.total_budget_executed
      end
    end

    def test_total_budget_executed_percentage
      # when no data
      assert_nil stats.total_budget_executed_percentage

      # when initial estimate
      f1 = total(forecast: 100)
      f2 = total(executed: 50)

      with factories: [f1, f2] do
        assert_equal 50, stats.total_budget_executed_percentage
      end

      # when updated data
      f1 = total(forecast: 100)
      f2 = total(executed: 50)
      f3 = total(forecast_updated: 150)

      with factories: [f1, f2, f3] do
        assert_equal 33, stats.total_budget_executed_percentage
      end
    end

    def test_budgets_execution_summary
      # when no data
      expenses = stats.budgets_execution_summary.last_expenses
      income = stats.budgets_execution_summary.last_income

      assert_nil expenses.budgeted
      assert_nil expenses.budgeted_updated
      assert_nil expenses.execution

      assert_nil income.budgeted
      assert_nil income.budgeted_updated
      assert_nil income.execution

      # when updated data
      with factories: [total, total_income] do
        expenses = stats.budgets_execution_summary.last_expenses
        income = stats.budgets_execution_summary.last_income

        refute_nil expenses.budgeted
        refute_nil expenses.budgeted_updated
        refute_nil expenses.execution

        refute_nil income.budgeted
        refute_nil income.budgeted_updated
        refute_nil income.execution
      end
    end

    def test_percentage_difference
      f1 = total(forecast: TOTAL_BUDGET)
      f2 = total(executed: TOTAL_BUDGET/2)

      with factories: [f1, f2] do
        assert_equal "100.00 % more", stats.percentage_difference(variable1: :total_budget, variable2: :total_budget_executed, year: Date.today.year)
      end
    end
  end
end
