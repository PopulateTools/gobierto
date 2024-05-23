# frozen_string_literal: true

require_relative "budgets_factory"

class TotalBudgetFactory

  include BudgetsFactory

  TYPE = GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type

  def build_document(index, params = {})
    population = params[:population] || self.class.default_population
    total_budget = params[:total_budget] || self.class.default_amount
    kind = params[:kind] || self.class.default_kind

    {
      index: {
        _index: index,
        _id: self.class.doc_id(params, TYPE),
        data: self.class.base_data(params).merge(
          type: TYPE,
          kind: kind,
          amount: total_budget,
          amount_per_inhabitant: (total_budget / population).round(2)
        )
      }
    }
  end

  def self.doc_id(params = {}, type)
    organization_id = params[:organization_id] || default_organization_id
    year = params[:year] || default_year
    kind = params[:kind] || default_kind

    [organization_id, year, kind, type].join("/")
  end

end
