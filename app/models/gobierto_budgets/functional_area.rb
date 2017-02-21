module GobiertoBudgets
  class FunctionalArea
    include Describable

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
          source['kind'] = GobiertoBudgets::BudgetLine.budget_kind_for source['kind']
          all_items[source['kind']][source['code']] = source['name']
        end

        all_items
      end
    end

    def self.area_name
      'functional'
    end

    def self.valid_kinds
      [GobiertoBudgets::BudgetLine::BUDGET_KINDS[:expense]]
    end

  end
end
