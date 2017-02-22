module GobiertoBudgets
  class EconomicArea
    include Describable

    def self.all_items
      @all_items ||= begin
        all_items = {
          GobiertoBudgets::BudgetLine::BUDGET_KINDS[:expense] => {},
          GobiertoBudgets::BudgetLine::BUDGET_KINDS[:income] => {}
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
          source['kind'] = GobiertoBudgets::BudgetLine.budget_kind_for source['kind']
          all_items[source['kind']][source['code']] = source['name']
        end

        all_items
      end
    end

    def self.area_name
      'economic'
    end

    def self.valid_kinds
      [GobiertoBudgets::BudgetLine::BUDGET_KINDS[:income], GobiertoBudgets::BudgetLine::BUDGET_KINDS[:expense]]
    end

  end
end
