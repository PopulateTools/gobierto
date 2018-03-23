# frozen_string_literal: true

module GobiertoBudgets
  class FunctionalArea < BudgetArea
    def self.area_name
      "functional"
    end

    def self.available_kinds
      [BudgetLine::EXPENSE]
    end
  end
end
