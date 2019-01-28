# frozen_string_literal: true

namespace :gobierto_budgets do
  namespace :elastic_search_schemas do
    namespace :manage do
      def indexes
        GobiertoBudgets::SearchEngineConfiguration::BudgetLine.all_indices +
          GobiertoBudgets::SearchEngineConfiguration::Invoice.all_indices
      end

      def types
        GobiertoBudgets::BudgetArea.all_areas_names +
          [GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type]
      end

      def create_invoices_mapping(index, type)
        m = GobiertoBudgets::SearchEngine.client.indices.get_mapping index: index, type: type
        return unless m.empty?

        puts "  - Creating #{index} #{type}"
        GobiertoBudgets::SearchEngine.client.indices.put_mapping index: index, type: type, body: {
          type.to_sym => {
            properties: {
              value:                       { "type": "float", "index": "not_analyzed" },
              location_id:                 { "type": "string", "index": "not_analyzed" },
              date:                        { "type": "date", "index": "not_analyzed" },
              province_id:                 { "type": "integer", "index": "not_analyzed" },
              autonomous_region_id:        { "type": "integer", "index": "not_analyzed" },
              invoice_id:                  { "type": "string", "index": "not_analyzed" },
              provider_id:                 { "type": "string", "index": "not_analyzed" },
              provider_name:               { "type": "string", "index": "analyzed" },
              payment_date:                { "type": "date", "index": "not_analyzed" },
              paid:                        { "type": "boolean", "index": "not_analyzed" },
              subject:                     { "type": "string", "index": "analyzed" },
              freelance:                   { "type": "boolean", "index": "not_analyzed" },
              economic_budget_line_code:   { "type": "string", "index": "not_analyzed" },
              functional_budget_line_code: { "type": "string", "index": "not_analyzed" }
            }
          }
        }
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
            elsif index == GobiertoBudgets::SearchEngineConfiguration::Invoice.index
              create_invoices_mapping(index, GobiertoBudgets::SearchEngineConfiguration::Invoice.type)
            else
              create_budgets_mapping(index, type)
            end
          end
        end
      end
    end
  end
end
