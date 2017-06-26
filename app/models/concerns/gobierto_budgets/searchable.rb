module GobiertoBudgets
  module Searchable
    extend ActiveSupport::Concern

    class_methods do

      def any_items?(options = {})
        query = {
          query: {
            filtered: {
              filter: {
                bool: {
                  must: [
                    { term: { ine_code: options[:place].id.to_i } },
                    { term: { area: area_name } },
                    { term: { kind: (options[:kind] == GobiertoBudgets::BudgetLine::INCOME ? 'income' : 'expense') } }
                  ]
                }
              }
            }
          },
          size: 1
        }

        response = execute_query(query)

        response['hits']['hits'].any?
      end

      def all_items
        @all_items ||= {}
        @all_items[I18n.locale] ||= begin
          all_items = Hash[ available_kinds.map { |kind| [kind, {}] } ]

          query = {
            query: {
              filtered: {
                filter: {
                  bool: {
                    must: [
                      { term: { area: area_name } },
                    ]
                  }
                }
              }
            },
            size: 10_000
          }

          response = execute_query(query)

          response['hits']['hits'].each do |h|
            source = h['_source']
            source['kind'] = source['kind'] == 'income' ? BudgetLine::INCOME : BudgetLine::EXPENSE
            all_items[source['kind']][source['code']] = source['name']
          end

          all_items
        end
      end

      def execute_query(query)
        SearchEngine.client.search(
          index: SearchEngineConfiguration::BudgetCategories.index,
           type: SearchEngineConfiguration::BudgetCategories.type,
           body: query
        )
      end

    end

  end
end
