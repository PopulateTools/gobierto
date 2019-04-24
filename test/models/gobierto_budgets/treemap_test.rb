# frozen_string_literal: true

require "test_helper"
require "factories/budget_line_factory"

module GobiertoBudgets
  class TreemapTest < ActiveSupport::TestCase

    AMOUNT = 5_000
    UPDATED_AMOUNT = 10_000

    def organization_id
      @organization_id ||= sites(:huesca).organization_id
    end

    def treemap
      ::GobiertoBudgets::Data::Treemap.new(
        organization_id: organization_id,
        year: Date.today.year,
        kind: GobiertoBudgets::BudgetLine::EXPENSE,
        type: GobiertoBudgets::EconomicArea.area_name,
        level: 2
      )
    end

    def treemap_children
      JSON.parse(treemap.generate_json)["children"]
    end

    def budget_line(params = {})
      BudgetLineFactory.new(params.merge(organization_id: organization_id, level: 2))
    end

    def test_generate_json
      # when no data
      assert treemap_children.empty?

      # when initial estimate
      with factory: budget_line(amount: AMOUNT, indexes: [:forecast]) do
        assert_equal AMOUNT, treemap_children.first["budget"]
      end

      # when updated data
      f1 = budget_line(amount: AMOUNT, indexes: [:forecast])
      f2 = budget_line(amount: UPDATED_AMOUNT, indexes: [:forecast_updated])

      with factories: [f1, f2] do
        assert_equal UPDATED_AMOUNT, treemap_children.first["budget"]
      end
    end

  end
end
