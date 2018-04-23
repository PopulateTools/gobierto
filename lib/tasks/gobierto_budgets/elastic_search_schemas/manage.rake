# frozen_string_literal: true

namespace :gobierto_budgets do
  namespace :elastic_search_schemas do
    namespace :manage do
      def indexes
        [GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
         GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed,
         GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed_series,
         GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast_updated]
      end

      def types
        GobiertoBudgets::BudgetArea.all_areas_names
      end

      def create_budgets_mapping(index, type)
        m = GobiertoBudgets::SearchEngine.client.indices.get_mapping index: index, type: type
        return unless m.empty?

        puts "  - Creating #{index} #{type}"
        # BUDGETS_INDEX: budgets-forecast // budgets-execution
        # BUDGETS_TYPE: economic // functional // custom
        #
        # Document identifier: <ine_code>/<year>/<code>/<kind>
        #
        # Example: 28079/2015/210.00/0
        # Example: 28079/2015/210.00/1
        GobiertoBudgets::SearchEngine.client.indices.put_mapping index: index, type: type, body: {
          type.to_sym => {
            properties: {
              ine_code:              { type: 'integer', index: 'not_analyzed' },
              organization_id:       { type: 'string',  index: 'not_analyzed' },
              year:                  { type: 'integer', index: 'not_analyzed' },
              amount:                { type: 'double', index: 'not_analyzed'  },
              code:                  { type: 'string', index: 'not_analyzed'  },
              parent_code:           { type: 'string', index: 'not_analyzed'  },
              functional_code:       { type: 'string', index: 'not_analyzed'  },
              custom_code:           { type: 'string', index: 'not_analyzed'  },
              level:                 { type: 'integer', index: 'not_analyzed' },
              kind:                  { type: 'string', index: 'not_analyzed'  }, # income I / expense G
              province_id:           { type: 'integer', index: 'not_analyzed' },
              autonomy_id:           { type: 'integer', index: 'not_analyzed' },
              amount_per_inhabitant: { type: 'double', index: 'not_analyzed'  }
            }
          }
        }
      end

      def create_budgets_execution_series_mapping(index, type)
        m = GobiertoBudgets::SearchEngine.client.indices.get_mapping index: index, type: type
        return unless m.empty?

        puts "  - Creating #{index} #{type}"
        # BUDGETS_INDEX: gobierto-budgets-execution-series
        # BUDGETS_TYPE: economic // functional // custom
        #
        # Document identifier: <ine_code>/<code>/<kind>
        # Example: 28079/101/I
        GobiertoBudgets::SearchEngine.client.indices.put_mapping index: index, type: type, body: {
          type.to_sym => {
            properties: {
              ine_code:        { type: 'integer', index: 'not_analyzed' },
              organization_id: { type: 'string',  index: 'not_analyzed' },
              kind:            { type: 'string',  index: 'not_analyzed' },  # income I / expense G
              code:            { type: 'string',  index: 'not_analyzed' },
              values: {
                properties: {
                  date:        { type: 'string',  index: 'not_analyzed' },
                  amount:      { type: 'double',  index: 'not_analyzed' }
                }
              }
            }
          }
        }
      end

      desc 'Reset ElasticSearch'
      task :reset => :environment do

        indexes.each do |index|
          if GobiertoBudgets::SearchEngine.client.indices.exists? index: index
            puts "- Deleting #{index}..."
            GobiertoBudgets::SearchEngine.client.indices.delete index: index
          end
        end
      end

      desc 'Create mappings'
      task :create => :environment do
        indexes.each do |index|
          unless GobiertoBudgets::SearchEngine.client.indices.exists? index: index
            puts "- Creating index #{index}"
            GobiertoBudgets::SearchEngine.client.indices.create index: index, body: {
              settings: {
                # Allow 100_000 results per query
                index: { max_result_window: 100_000 }
              }
            }
          end

          types.each do |type|
            if index == GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed_series
              create_budgets_execution_series_mapping(index, type)
            else
              create_budgets_mapping(index, type)
            end
          end
        end
      end
    end
  end
end
