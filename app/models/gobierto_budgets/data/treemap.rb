# frozen_string_literal: true

module GobiertoBudgets
  module Data
    class Treemap
      def initialize(options)
        @organization_id = options[:organization_id]
        @site = options[:site] || Site.find_by(organization_id: @organization_id)
        @kind = options[:kind]
        @type = options[:type]
        @year = options[:year]
        @parent_code = options[:parent_code]
        @level = options[:level] || 1
      end

      def generate_json
        areas = BudgetArea.klass_for(@type)

        children_json = budget_lines_hits.map do |h|
          {
            name: BudgetLinePresenter.load("#{h["_id"]}/#{h["_type"]}", @site).name,
            code: h["_source"]["code"],
            budget: h["_source"]["amount"],
            budget_per_inhabitant: h["_source"]["amount_per_inhabitant"]
          }
        end

        {
          name: @type,
          children: children_json
        }.to_json
      end

      private

      def budget_lines_hits
        hits = SearchEngine.client.search(index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast_updated, body: query)["hits"]["hits"]

        if hits.empty?
          hits = SearchEngine.client.search(index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, body: query)["hits"]["hits"]
        end

        hits
      end

      def query
        @query ||= begin
          q = ESQueryBuilder.must(
            organization_id: @organization_id,
            kind: @kind,
            year: @year,
            type: @type
          ).merge(
            sort: [ { amount: { order: "desc" } } ],
            size: ESQueryBuilder::MAX_SIZE
          )

          if @parent_code.nil?
            q[:query][:bool][:must].push(term: { level: @level })
          else
            q[:query][:bool][:must].push(term: { parent_code: @parent_code })
          end

          q
        end
      end

    end
  end
end
