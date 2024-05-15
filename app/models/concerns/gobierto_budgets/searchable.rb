module GobiertoBudgets
  module Searchable
    extend ActiveSupport::Concern

    class_methods do

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
          index: GobiertoBudgetsData::GobiertoBudgets::BudgetCategories.index,
           type: GobiertoBudgetsData::GobiertoBudgets::BudgetCategories.type,
           body: query
        )
      end

    end

  end
end
