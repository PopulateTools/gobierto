module GobiertoBudgets
  class FunctionalArea
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
          all_items[source['kind']][source['code']] = source['name']
        end

        all_items
      end
    end

    def self.all_descriptions
      @all_descriptions ||= begin
        YAML.load_file('./db/data/budget_line_descriptions.yml')['functional']
      end
    end
  end
end
