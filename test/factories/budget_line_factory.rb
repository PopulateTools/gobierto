# frozen_string_literal: true

require_relative "budgets_factory"

class BudgetLineFactory

  include BudgetsFactory

  private

  def default_amount
    123_456.789
  end

  def amount_per_inhabitant(amount, population)
    (amount / population).round(2)
  end

  def build_document(index, params = {})
    amount = params[:amount] || self.class.default_amount
    population = params[:population] || self.class.default_population
    organization_id = params[:organization_id] || self.class.default_organization_id

    {
      index: {
        _index: index,
        _id: self.class.default_doc_id,
        _type: self.class.default_area,
        data: self.class.default_attrs.merge(
          amount: amount,
          population: population,
          amount_per_inhabitant: amount_per_inhabitant(amount, population)
        )
      }
    }
  end

  def self.default_doc_id
    [default_organization_id, default_year, default_code, default_kind].join("/")
  end

  def self.default_attrs
    base_data.merge(
      code: default_code,
      level: default_code.length,
      kind: default_kind,
      population: default_population
    )
  end

end
