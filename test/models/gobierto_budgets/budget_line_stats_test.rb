# frozen_string_literal: true

require "test_helper"
require "factories/budget_line_factory"

module GobiertoBudgets
  class BudgetLineStatsTest < ActiveSupport::TestCase

    def site
      @site ||= sites(:madrid)
    end

    def budget_line_attrs
      {
        site: site,
        code: BudgetLineFactory.default_code,
        year: 2019,
        kind: BudgetLineFactory.default_kind,
        area_name: BudgetLineFactory.default_area
      }
    end

    def budget_line
      @budget_line ||= GobiertoBudgets::BudgetLine.first(where: budget_line_attrs)
    end

    def budget_line_stats
      @budget_line_stats ||= GobiertoBudgets::BudgetLineStats.new(site: site, budget_line: budget_line)
    end

    def test_amounts
      amount = 150.11
      amount_updated = 200.22
      population = 10

      factory_1 = BudgetLineFactory.new(population: population, amount: amount, indexes: [:forecast])
      factory_2 = BudgetLineFactory.new(population: population, amount: amount_updated, indexes: [:forecast_updated])

      assert_equal amount, budget_line_stats.amount
      assert_equal amount_updated, budget_line_stats.amount_updated
      assert_equal 15.01, budget_line_stats.amount_per_inhabitant
      assert_equal 20.02, budget_line_stats.amount_per_inhabitant_updated

      factory_1.teardown
      factory_2.teardown
    end

  end
end
