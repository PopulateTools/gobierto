# frozen_string_literal: true

module GobiertoBudgets
  class TopBudgetLine
    def self.limit(n)
      @limit = n
      self
    end

    def self.where(conditions)
      @conditions = conditions
      self
    end

    def self.all
      area = (@conditions[:kind] == BudgetLine::INCOME ? EconomicArea : FunctionalArea)

      terms = [
        { term: { kind: @conditions[:kind] } },
        { term: { year: @conditions[:year] } },
        { term: { level: 3 } },
        { term: { organization_id: @conditions[:site].organization_id } },
        { term: { type: area.area_name } }
      ]

      query = {
        sort: [
          { amount: { order: "desc" } }
        ],
        query: {
          bool: {
            must: terms
          }
        },
        size: @limit
      }

      total = BudgetTotal.for(@conditions[:site].organization_id, @conditions[:year])

      response = SearchEngine.client.search index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, body: query

      response["hits"]["hits"].map { |h| h["_source"] }.map do |row|
        GobiertoBudgets::BudgetLinePresenter.new(row.merge(
                                                   site: @conditions[:site],
                                                   kind: @conditions[:kind],
                                                   area: area,
                                                   area_name: area.area_name,
                                                   total: total
        ))
      end
    end
  end
end
