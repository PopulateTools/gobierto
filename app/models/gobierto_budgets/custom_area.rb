module GobiertoBudgets
  class CustomArea < BudgetArea

    def self.any_items?(options = {})
      GobiertoBudgets::Category.where(site: options[:site], kind: options[:kind]).any?
    end

    def self.area_name
      'custom'
    end

    def self.available_kinds
      [BudgetLine::INCOME, BudgetLine::EXPENSE]
    end

  end
end
