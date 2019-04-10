# frozen_string_literal: true

module GobiertoBudgets
  def self.table_name_prefix
    'gb_'
  end

  def self.searchable_models
    [ GobiertoBudgets::BudgetLine ]
  end

  def self.doc_url
    "https://gobierto.readme.io/docs/presupuestos"
  end
end
