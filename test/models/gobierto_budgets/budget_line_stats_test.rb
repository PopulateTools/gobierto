# frozen_string_literal: true

require "test_helper"
require "factories/budget_line_factory"
require "factories/total_budget_factory"

module GobiertoBudgets
  class BudgetLineStatsTest < ActiveSupport::TestCase

    def site
      @site ||= sites(:madrid)
    end

    def huesca
      @huesca ||= sites(:huesca)
    end

    def fraga
      INE::Places::Place.find_by_slug("fraga")
    end

    def barbastro
      INE::Places::Place.find_by_slug("barbastro")
    end

    UPDATED_BUDGET_RATIO = 1.25
    EXECUTED_BUDGET_RATIO = 0.5
    TOTAL_BUDGET_RATIO = 10

    def amount; 150.0 end
    def amount_updated; amount * UPDATED_BUDGET_RATIO end
    def amount_executed; amount * EXECUTED_BUDGET_RATIO end
    def population; 10 end

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

    def setup
      @factories = [
        BudgetLineFactory.new(population: population, amount: amount, indexes: [:forecast]),
        BudgetLineFactory.new(population: population, amount: amount_executed, indexes: [:executed]),
        TotalBudgetFactory.new(population: population, total_budget: amount * TOTAL_BUDGET_RATIO, indexes: [:forecast]),
        TotalBudgetFactory.new(population: population, total_budget: amount_executed * TOTAL_BUDGET_RATIO, indexes: [:executed]),
      ]
    end

    def teardown
      @factories.map(&:teardown)
    end

    def setup_updated_budget
      BudgetLineFactory.new(population: population, amount: amount_updated, indexes: [:forecast_updated])
    end

    # use different province to avoid conflicts with fixtures
    def setup_province_budgets(params = {})
      default_attrs = { organization_id: huesca.organization_id, population: population }

      factories = [
        BudgetLineFactory.new(default_attrs.merge(place: fraga, amount: 20, indexes: [:forecast])),
        BudgetLineFactory.new(default_attrs.merge(place: barbastro, amount: 10, indexes: [:forecast]))
      ]

      if params[:updated_budgets]
        factories << BudgetLineFactory.new(default_attrs.merge(place: fraga, amount: 50, indexes: [:forecast_updated]))
      end

      budget_line = GobiertoBudgets::BudgetLine.first(where: budget_line_attrs.merge(site: huesca))
      budget_line_stats = GobiertoBudgets::BudgetLineStats.new(site: huesca, budget_line: budget_line)

      return factories, budget_line_stats
    end

    def test_amounts
      factory = setup_updated_budget

      assert_equal amount, budget_line_stats.amount
      assert_equal amount_updated, budget_line_stats.amount_updated
      assert_equal amount/population, budget_line_stats.amount_per_inhabitant
      assert_equal amount_updated/population, budget_line_stats.amount_per_inhabitant_updated
      assert_equal amount_executed, budget_line_stats.amount_executed

      factory.teardown
    end

    def test_execution_percentage_when_updated_budget_is_not_available
      expected_percentage = "#{EXECUTED_BUDGET_RATIO * 100}0 %"

      assert_equal expected_percentage, budget_line_stats.execution_percentage
    end

    def test_execution_percentage_when_updated_budget_is_available
      factory = setup_updated_budget

      with(factory: factory) do
        assert_equal "40.00 %", budget_line_stats.execution_percentage
      end
    end

    def test_percentage_of_total_when_updated_budget_is_not_available
      assert_equal "#{TOTAL_BUDGET_RATIO}.00 %", budget_line_stats.percentage_of_total
    end

    def test_percentage_of_total_when_updated_budget_is_available
      factory = setup_updated_budget

      with(factory: factory) do
        assert_equal "12.50 %", budget_line_stats.percentage_of_total
      end
    end

    def test_mean_province
      factories, stats = setup_province_budgets

      with(factories: factories) do
        assert_equal 15.0, stats.mean_province
      end
    end

    def test_mean_province_ignores_updated_amount
      factories, stats = setup_province_budgets(updated_budgets: true)

      with(factories: factories) do
        assert_equal 15.0, stats.mean_province
      end
    end

  end
end
