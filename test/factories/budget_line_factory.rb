# frozen_string_literal: true

require_relative "budgets_factory"

class BudgetLineFactory

  include BudgetsFactory

  private

  def amount_per_inhabitant(amount, population)
    (amount / population).round(2)
  end

  def build_document(index, params = {})
    amount = params[:amount] || self.class.default_amount
    population = params[:population] || self.class.default_population

    {
      index: {
        _index: index,
        _id: self.class.doc_id(params),
        _type: self.class.default_area,
        data: self.class.base_attrs(params).merge(
          amount: amount,
          population: population,
          amount_per_inhabitant: amount_per_inhabitant(amount, population)
        )
      }
    }
  end

  def self.doc_id(params = {})
    place = params[:place] || default_place
    year = params[:year] || default_year

    [place.id, year, default_code, default_kind].join("/")
  end

  def self.base_attrs(params = {})
    base_data(params).merge(
      code: default_code,
      level: default_code.length,
      kind: default_kind,
      population: default_population
    )
  end

end
