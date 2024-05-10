# frozen_string_literal: true

module GobiertoBudgets
  class BudgetLineStats

    attr_accessor :year

    def initialize(options)
      @site = options.fetch :site
      @organization_id = @site.organization_id
      @budget_line = options.fetch :budget_line
      @kind = @budget_line.kind
      @area_name = @budget_line.area_name
      @year = @budget_line.year.to_i
      @code = @budget_line.code
    end

    def amount(year = nil)
      budget_line_planned_query(year, "amount")
    end
    alias amount_planned amount

    def amount_updated(year = nil, fallback = false)
      result = budget_line_planned_updated_query(year, "amount")
      result = amount(year) if fallback && result.nil?

      result
    end

    def amount_executed(year = nil)
      budget_line_executed_query(year, "amount")
    end

    def amount_per_inhabitant(year = nil)
      budget_line_planned_query(year, "amount_per_inhabitant")
    end

    def amount_per_inhabitant_updated(year = nil)
      budget_line_planned_updated_query(year, "amount_per_inhabitant")
    end

    def percentage_of_total(year = nil)
      return "" if total_budget.nil?

      diff = amount_updated(year, true) / total_budget
      if diff
        diff = diff.to_f * 100

        "#{ ActionController::Base.helpers.number_with_precision(diff, precision: 2) } %"
      else
        ""
      end
    end

    def percentage_difference(options)
      year = options.fetch(:year, @year)
      variable1 = options.fetch(:variable1)
      variable2 = options.fetch(:variable2, options.fetch(:variable1))

      if variable1 == variable2
        year1 = options.fetch(:year1)
        year2 = options.fetch(:year2)

        v1 = send(variable1, year1)
        v2 = send(variable1, year2)
      else
        v1 = send(variable1, year)
        v2 = send(variable2, year)
      end
      return nil if v1.nil? || v2.nil?
      diff = ((v1.to_f - v2.to_f) / v2.to_f) * 100

      return nil if diff == Float::INFINITY

      diff += 100

      "#{ ActionController::Base.helpers.number_with_precision(diff, precision: 2) } %"
    end

    def mean_province
      mean_province_query(@year, "amount")
    end

    def execution_percentage(requested_year = year)
      @execution_percentage ||= begin
        variable2 = amount_updated ? :amount_updated : :amount_planned
        percentage_difference(variable1: :amount_executed, variable2: variable2, year: requested_year)
      end
    end

    private

    def total_budget
      total_budget_planned_query(@year, "total_budget")
    end

    def budget_line_planned_query(year, attribute)
      year ||= @year
      result = GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: @area_name, id: [@organization_id, year, @code, @kind].join("/")
      result["_source"][attribute]
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def budget_line_planned_updated_query(year, attribute)
      year ||= @year
      result = GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast_updated, type: @area_name, id: [@organization_id, year, @code, @kind].join("/")
      result["_source"][attribute]
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def budget_line_executed_query(year, attribute)
      year ||= @year
      result = GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed, type: @area_name, id: [@organization_id, year, @code, @kind].join("/")
      result["_source"][attribute]
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def total_budget_planned_query(year, attribute)
      result = GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::TotalBudget.index_forecast,
                                                        type: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type, id: [@organization_id, year, @kind].join("/")
      result["_source"][attribute].to_f
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def mean_province_query(year, attribute)
      filters = []
      filters.push(term: { province_id: @site.place.province_id }) if @site.place.present?
      filters.push(term: { code: @code })
      filters.push(term: { kind: @kind })
      filters.push(term: { year: year })

      query = {
        query: {
          filtered: {
            filter: {
              bool: {
                must: filters
              }
            }
          }
        },
        size: 10_000,
        "aggs": {
          "#{attribute}_per_year": {
            "terms": {
              "field": "year",
              size: 10_000
            },
            "aggs": {
              "budget_sum": {
                "sum": {
                  "field": attribute.to_s
                }
              }
            }
          }
        }
      }

      response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: @area_name, body: query

      result = nil
      response["aggregations"]["#{ attribute }_per_year"]["buckets"].each do |r|
        result = (r["budget_sum"]["value"].to_f / r["doc_count"].to_f).round(2)
      end
      result
    end
  end
end
