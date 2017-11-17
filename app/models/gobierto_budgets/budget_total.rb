module GobiertoBudgets
  class BudgetTotal
    TOTAL_FILTER_MIN = 0
    TOTAL_FILTER_MAX = 5000000000
    PER_INHABITANT_FILTER_MIN = 0
    PER_INHABITANT_FILTER_MAX = 20000
    BUDGETED = 'B'
    EXECUTED = 'E'
    BUDGETED_UPDATED = 'BU'

    def self.budgeted_updated_for(ine_code, year, kind = BudgetLine::EXPENSE)
      return BudgetTotal.for(ine_code, year, BudgetTotal::BUDGETED_UPDATED, kind)
    end

    def self.budgeted_for(ine_code, year, kind = BudgetLine::EXPENSE)
      return BudgetTotal.for(ine_code, year, BudgetTotal::BUDGETED, kind)
    end

    def self.execution_for(ine_code, year, kind = BudgetLine::EXPENSE)
      return BudgetTotal.for(ine_code, year, BudgetTotal::EXECUTED, kind)
    end

    def self.for(ine_code, year, index = BudgetTotal::BUDGETED, kind = BudgetLine::EXPENSE)
      return for_places(ine_code, year) if ine_code.is_a?(Array)
      index = case index
              when BudgetTotal::EXECUTED
                SearchEngineConfiguration::TotalBudget.index_executed
              when BudgetTotal::BUDGETED
                SearchEngineConfiguration::TotalBudget.index_forecast
              when BudgetTotal::BUDGETED_UPDATED
                SearchEngineConfiguration::TotalBudget.index_forecast_updated
              end


      result = SearchEngine.client.get( index: index, type: SearchEngineConfiguration::TotalBudget.type, id: [ine_code, year, kind].join('/'))

      result = result['_source']['total_budget'].to_f
      result == 0.0 ? nil : result
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def self.budget_evolution_for(ine_code, b_or_e = BudgetTotal::BUDGETED, kind = BudgetLine::EXPENSE)
      query = {
        sort: [
          { year: { order: 'asc' } }
        ],
        query: {
          filtered: {
            filter: {
              bool: {
                must: [
                  {term: {ine_code: ine_code}},
                  {term: {kind: kind}}
                ]
              }
            }
          }
        },
        size: 10000
      }

      index = index = (b_or_e == BudgetTotal::EXECUTED) ? SearchEngineConfiguration::TotalBudget.index_executed : SearchEngineConfiguration::TotalBudget.index_forecast

      response = SearchEngine.client.search index: index, type: SearchEngineConfiguration::TotalBudget.type, body: query
      response['hits']['hits'].map{ |h| h['_source'] }
    end

    def self.for_places(ine_codes, year)
      terms = [{terms: {ine_code: ine_codes}},
               {term: {year: year}}]

      query = {
        query: {
          filtered: {
            filter: {
              bool: {
                must: terms
              }
            }
          }
        },
        size: 10000
      }

      response = SearchEngine.client.search index: SearchEngineConfiguration::TotalBudget.index_forecast, type: SearchEngineConfiguration::TotalBudget.type, body: query
      return response['hits']['hits'].map{ |h| h['_source'] }
    end
  end
end
