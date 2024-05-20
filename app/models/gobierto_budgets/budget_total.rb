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
    CONFIG = GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::TotalBudget

    def self.budgeted_updated_for(params = {})
      organization_id = params[:organization_id]
      year = params[:year]
      kind = params[:kind] || BudgetLine::EXPENSE

      result = BudgetTotal.for(organization_id, year, BudgetTotal::BUDGETED_UPDATED, kind)

      if result.nil? && params[:fallback] == true
        BudgetTotal.budgeted_for(organization_id, year, kind)
      else
        result
      end
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
                CONFIG.index_executed
              when BudgetTotal::BUDGETED
                CONFIG.index_forecast
              when BudgetTotal::BUDGETED_UPDATED
                CONFIG.index_forecast_updated
              end

      doc_id = [organization_id, year, kind, CONFIG.type].join("/")

      result = SearchEngine.client.get(index: index, id: doc_id)
      result = result["_source"]["amount"].to_f
      result == 0.0 ? nil : result
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def self.for_organizations(organization_ids, year)
      query = ESQueryBuilder.must(
        organization_id: organization_ids,
        year: year,
        type: CONFIG.type,
      ).merge(
        size: ESQueryBuilder::MAX_SIZE
      )

      response = SearchEngine.client.search(
        index: CONFIG.index_forecast,
        body: query
      )

      response["hits"]["hits"].map { |h| h["_source"] }
    end
  end
end
