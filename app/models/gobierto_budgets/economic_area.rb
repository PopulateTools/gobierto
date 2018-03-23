# frozen_string_literal: true

module GobiertoBudgets
  class EconomicArea < BudgetArea
    def self.area_name
      "economic"
    end

    def self.available_kinds
      [BudgetLine::INCOME, BudgetLine::EXPENSE]
    end
  end
end
