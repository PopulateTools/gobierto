# frozen_string_literal: true

module GobiertoBudgets
  class BudgetTotal
    TOTAL_FILTER_MIN = 0
    TOTAL_FILTER_MAX = 5_000_000_000
    PER_INHABITANT_FILTER_MIN = 0
    PER_INHABITANT_FILTER_MAX = 20_000
    BUDGETED = "B"
    EXECUTED = "E"
    BUDGETED_UPDATED = "BU"

    def self.budgeted_updated_for(organization_id, year, kind = BudgetLine::EXPENSE)
      BudgetTotal.for(organization_id, year, BudgetTotal::BUDGETED_UPDATED, kind)
    end

    def self.budgeted_for(organization_id, year, kind = BudgetLine::EXPENSE)
      BudgetTotal.for(organization_id, year, BudgetTotal::BUDGETED, kind)
    end

    def self.execution_for(organization_id, year, kind = BudgetLine::EXPENSE)
      BudgetTotal.for(organization_id, year, BudgetTotal::EXECUTED, kind)
    end

    def self.for(organization_id, year, index = BudgetTotal::BUDGETED, kind = BudgetLine::EXPENSE)
      return for_organizations(organization_id, year) if organization_id.is_a?(Array)

      index = case index
              when BudgetTotal::EXECUTED
                SearchEngineConfiguration::TotalBudget.index_executed
              when BudgetTotal::BUDGETED
                SearchEngineConfiguration::TotalBudget.index_forecast
              when BudgetTotal::BUDGETED_UPDATED
                SearchEngineConfiguration::TotalBudget.index_forecast_updated
              end

      result = SearchEngine.client.get(index: index, type: SearchEngineConfiguration::TotalBudget.type, id: [organization_id, year, kind].join("/"))

      result = result["_source"]["total_budget"].to_f
      result == 0.0 ? nil : result
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def self.budget_evolution_for(organization_id, b_or_e = BudgetTotal::BUDGETED, kind = BudgetLine::EXPENSE)
      query = {
        sort: [
          { year: { order: "asc" } }
        ],
        query: {
          filtered: {
            filter: {
              bool: {
                must: [
                  { term: { organization_id: organization_id } },
                  { term: { kind: kind } }
                ]
              }
            }
          }
        },
        size: 10_000
      }

      index = index = b_or_e == BudgetTotal::EXECUTED ? SearchEngineConfiguration::TotalBudget.index_executed : SearchEngineConfiguration::TotalBudget.index_forecast

      response = SearchEngine.client.search index: index, type: SearchEngineConfiguration::TotalBudget.type, body: query
      response["hits"]["hits"].map { |h| h["_source"] }
    end

    def self.for_organizations(organization_ids, year)
      terms = [{ terms: { organization_id: organization_ids } },
               { term: { year: year } }]

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
        size: 10_000
      }

      response = SearchEngine.client.search index: SearchEngineConfiguration::TotalBudget.index_forecast, type: SearchEngineConfiguration::TotalBudget.type, body: query
      response["hits"]["hits"].map { |h| h["_source"] }
    end
  end
end
