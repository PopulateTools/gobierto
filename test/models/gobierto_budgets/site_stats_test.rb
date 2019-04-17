# frozen_string_literal: true

require "test_helper"
require "factories/total_budget_factory"

module GobiertoBudgets
  class SiteStatsTest < ActiveSupport::TestCase

    UPDATED_BUDGET_RATIO = 1.25

    def subject_class; GobiertoBudgets::SiteStats end
    def population; 10 end
    def total_budget; 20_000 end
    def updated_total_budget; total_budget * UPDATED_BUDGET_RATIO end

    def setup
      subject_class.any_instance.stubs(:population).returns(population)
    end

    def site
      @site ||= sites(:madrid)
    end

    def stats
      subject_class.new(site: site, year: 2019)
    end

    def total(params)
      TotalBudgetFactory.new(
        population: population,
        total_budget: params.values.first,
        indexes: [params.keys.first]
      )
    end

    def test_total_budget_per_inhabitant
      # when no data
      assert_equal 0.0, stats.total_budget_per_inhabitant

      # when initial estimate
      with factory: total(forecast: total_budget) do
        assert_equal(total_budget/population, stats.total_budget_per_inhabitant)
      end

      # when updated data
      f1 = total(forecast: total_budget)
      f2 = total(forecast_updated: updated_total_budget)

      with factories: [f1, f2] do
        assert_equal(updated_total_budget/population, stats.total_budget_per_inhabitant)
      end
    end

    def test_total_budget
      # when no data
      assert_nil stats.total_budget

      # when initial estimate
      with factory: total(forecast: total_budget) do
        assert_equal total_budget, stats.total_budget
      end

      # when updated data
      f1 = total(forecast: total_budget)
      f2 = total(forecast_updated: updated_total_budget)

      with factories: [f1, f2] do
        assert_equal updated_total_budget, stats.total_budget
      end
    end

    def test_total_budget_executed
      # when no data
      assert_nil stats.total_budget_executed

      # when data
      with factory: total(executed: total_budget) do
        assert_equal total_budget, stats.total_budget_executed
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
