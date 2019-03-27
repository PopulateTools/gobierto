# frozen_string_literal: true

module GobiertoBudgets

  def self.table_name_prefix
    "gb_"
  end

  def self.searchable_models
    [GobiertoBudgets::BudgetLine]
  end

end
