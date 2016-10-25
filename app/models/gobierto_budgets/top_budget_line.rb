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
      terms = [
        {term: { kind: @conditions[:kind] }},
        {term: { year: @conditions[:year] }},
        {term: { level: 3 }},
        {term: { ine_code: @conditions[:place].id }}
      ]

      query = {
        sort: [
          { amount: { order: 'desc' } }
        ],
        query: {
          filtered: {
            filter: {
              bool: {
                must: terms
              }
            }
          }
        },
        size: @limit
      }

      if @conditions[:kind] == GobiertoBudgets::BudgetLine::INCOME
        type = 'economic'
        area = GobiertoBudgets::EconomicArea
      else
        type = 'functional'
        area = GobiertoBudgets::FunctionalArea
      end

      total = GobiertoBudgets::BudgetTotal.for(@conditions[:place].id, @conditions[:year])

      response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
                                                             type: type, body: query

      response['hits']['hits'].map{ |h| h['_source'] }.map do |row|
        BudgetLinePresenter.new(row.merge(kind: @conditions[:kind], area: area, area_name: type, total: total))
      end
    end
  end
end
