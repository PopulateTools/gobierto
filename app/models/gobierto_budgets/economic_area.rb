module GobiertoBudgets
  class EconomicArea
    include Describable

    EXPENSE = 'G'
    INCOME  = 'I'

    def self.all_items
      @all_items ||= {}
      @all_items[I18n.locale] ||= begin
        all_items = {
          EXPENSE => {},
          INCOME => {}
        }

        query = {
          query: {
            filtered: {
              filter: {
                bool: {
                  must: [
                    {term: { area: 'economic' }},
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
