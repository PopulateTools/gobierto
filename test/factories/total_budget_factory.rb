# frozen_string_literal: true

require_relative "budgets_factory"

class TotalBudgetFactory

  include BudgetsFactory

  TYPE = GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type

  def build_document(index, params = {})
    population = params[:population] || self.class.default_population
    total_budget = params[:total_budget] || self.class.default_amount

    {
      index: {
        _index: index,
        _id: self.class.doc_id(params),
        _type: TYPE,
        data: self.class.base_data.merge(
          kind: self.class.default_kind,
          total_budget: total_budget,
          total_budget_per_inhabitant: (total_budget / population).round(2)
        )
      }
    }
  end

  def self.doc_id(params = {})
    organization_id = params[:organization_id] || default_organization_id
    year = params[:year] || default_year
    kind = params[:kind] || default_kind

    [organization_id, year, kind].join("/")
  end

end
