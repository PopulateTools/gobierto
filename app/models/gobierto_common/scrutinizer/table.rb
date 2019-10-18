# frozen_string_literal: true

module GobiertoCommon
  module Scrutinizer
    class Table
      def initialize(args)
        @table_name = args[:table_name]
      end

      def record_model
        return Record if Record.table_name == @table_name

        Record.table_name = @table_name
        Record
      end

      def summary_columns
        record_model.columns.inject({}) do |result, column|
          result.update(
            column.name => inspector.stats(column)
          )
        end
      end

      def summary_table
        {
          table_name: @table_name,
          summary:
          {
            fields_count: record_model.columns.count,
            rows_count: record_model.count
          },
          fields_summaries: record_model.columns.inject({}) do |columns, column|
            columns.update(
              column.name => {
                type: column.type,
                sql_type: column.sql_type,
                stats: inspector.stats(column)
              }
            )
          end
        }
      end

      def inspector
        @inspector ||= TableInspectorQuery.new(relation: record_model.all)
      end
    end
  end
end
