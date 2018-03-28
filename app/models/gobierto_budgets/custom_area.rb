# frozen_string_literal: true

module GobiertoBudgets
  class CustomArea < BudgetArea
    def self.area_name
      "custom"
    end

    def self.available_kinds
      [BudgetLine::INCOME, BudgetLine::EXPENSE]
    end
  end
end
