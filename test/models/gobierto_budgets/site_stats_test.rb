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
      SUBJECT_CLASS.new(site: site, year: 2019)
    end

    def total(params)
      TotalBudgetFactory.new(
        organization_id: site.organization_id,
        population: POPULATION,
        total_budget: params.values.first,
        indexes: [params.keys.first]
      )
    end

    def test_total_budget_per_inhabitant
      # when no data
      assert_equal 0.0, stats.total_budget_per_inhabitant

      # when initial estimate
      with factory: total(forecast: TOTAL_BUDGET) do
        assert_equal(TOTAL_BUDGET / POPULATION, stats.total_budget_per_inhabitant)
      end

      # when updated data
      f1 = total(forecast: TOTAL_BUDGET)
      f2 = total(forecast_updated: UPDATED_TOTAL_BUDGET)

      with factories: [f1, f2] do
        assert_equal(UPDATED_TOTAL_BUDGET / POPULATION, stats.total_budget_per_inhabitant)
      end
    end

    def test_total_budget
      # when no data
      assert_nil stats.total_budget

      # when initial estimate
      with factory: total(forecast: TOTAL_BUDGET) do
        assert_equal TOTAL_BUDGET, stats.total_budget
      end

      # when updated data
      f1 = total(forecast: TOTAL_BUDGET)
      f2 = total(forecast_updated: UPDATED_TOTAL_BUDGET)

      with factories: [f1, f2] do
        assert_equal UPDATED_TOTAL_BUDGET, stats.total_budget
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

  end
end
