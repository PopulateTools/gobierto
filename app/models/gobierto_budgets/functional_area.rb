module GobiertoBudgets
  class FunctionalArea
    include Describable

    EXPENSE = 'G'

    def self.all_items
      @all_items ||= begin
        all_items = {
          EXPENSE => {}
        }

        query = {
          query: {
            filtered: {
              filter: {
                bool: {
                  must: [
                    {term: { area: 'functional' }},
                  ]
                }
              }
            }
          },
          size: 10_000
        }
        response = SearchEngine.client.search index: SearchEngineConfiguration::BudgetCategories.index, type: SearchEngineConfiguration::BudgetCategories.type, body: query

        response['hits']['hits'].each do |h|
          source = h['_source']
          source['kind'] = source['kind'] == 'income' ? 'I' : 'G'
          all_items[source['kind']][source['code']] = source['name']
        end

        all_items
      end
    end
  end
end
