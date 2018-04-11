# frozen_string_literal: true

module GobiertoBudgets
  module Data
    class Treemap
      def initialize(options)
        @organization_id = options[:organization_id]
        @kind = options[:kind]
        @type = options[:type]
        @year = options[:year]
        @parent_code = options[:parent_code]
        @level = options[:level] || 1
      end

      def generate_json
        options = [
          { term: { organization_id: @organization_id } },
          { term: { kind: @kind } },
          { term: { year: @year } }
        ]

        if @parent_code.nil?
          options.push(term: { level: @level })
        else
          options.push(term: { parent_code: @parent_code })
        end

        query = {
          sort: [
            { amount: { order: "desc" } }
          ],
          query: {
            filtered: {
              filter: {
                bool: {
                  must: options
                }
              }
            }
          },
          size: 10_000
        }

        areas = BudgetArea.klass_for(@type)

        response = SearchEngine.client.search index: SearchEngineConfiguration::BudgetLine.index_forecast, type: @type, body: query
        children_json = response["hits"]["hits"].map do |h|
          {
            name: areas.all_items[@kind][h["_source"]["code"]],
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
    end
  end
end
