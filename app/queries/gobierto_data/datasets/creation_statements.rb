# frozen_string_literal: true

require_dependency "gobierto_data"

module GobiertoData
  module Datasets
    class CreationStatements
      attr_reader :schema

      def initialize(dataset, source_file, schema, opts = {})
        @dataset = dataset
        @base_table_name = dataset.table_name
        @source_file = source_file
        @csv_separator = opts.fetch(:csv_separator, ",")
        @append = opts.fetch(:append, false)
        @use_stdin = opts.fetch(:use_stdin, false)
        @schema = schema.present? ? schema.deep_symbolize_keys : inspect_csv_schema(source_file, csv_separator: @csv_separator)
        @transform_functions = @schema.inject({}) do |functions, (column, params)|
          functions.update(
            column => SqlFunction::Transformation.new(
              function: params[:type],
              id: column,
              optional_params: params.fetch(:optional_params, {})
            )
          )
        end
      end

      def sql_code
        [
          create_raw_temp_table,
          create_transformed_temp_table,
          create_destination_table,
          extract_csv_operation,
          define_transform_functions,
          transform_operation,
          load_operation,
          clear_transform_functions
        ].join("\n")
      end

      def transaction_sql_code
        "BEGIN;\n#{sql_code}\nCOMMIT;"
      end

      private

      def create_raw_temp_table
        "CREATE TEMP TABLE #{@base_table_name}_raw(\n#{schema.map { |column, _| "#{column} TEXT" }.join(",\n")}\n);"
      end

      def create_transformed_temp_table
        "CREATE TEMP TABLE #{@base_table_name}_transformed(\n#{@transform_functions.map { |column, f| "#{column} #{f.output_type}" }.join(",\n")}\n);"
      end

      def create_destination_table
        if @append
          <<-SQL
          CREATE TABLE IF NOT EXISTS #{@base_table_name}(
            #{@transform_functions.map { |column, f| "#{column} #{f.output_type}" }.join(",\n")}
          );
          SQL
        else
          <<-SQL
          DROP TABLE IF EXISTS #{@base_table_name};
          CREATE TABLE #{@base_table_name}(
            #{@transform_functions.map { |column, f| "#{column} #{f.output_type}" }.join(",\n")}
          );
          SQL
        end
      end

      def extract_csv_operation
        if @use_stdin
          "COPY #{@base_table_name}_raw (#{schema.keys.join(", ")}) FROM STDIN DELIMITER '#{@csv_separator}' CSV HEADER NULL '';"
        else
          "COPY #{@base_table_name}_raw (#{schema.keys.join(", ")}) FROM '#{@source_file}' DELIMITER '#{@csv_separator}' CSV HEADER NULL '';"
        end
      end

      def define_transform_functions
        @transform_functions.values.map(&:function_definition).join("\n")
      end

      def clear_transform_functions
        @transform_functions.values.map(&:function_drop).join("\n")
      end

      def transform_operation
        <<-SQL
        INSERT INTO #{@base_table_name}_transformed (
          #{schema.keys.join(",\n")}
        )
        SELECT #{ @transform_functions.map { |column, f| f.function_call(column) }.join(",\n")}
        from #{@base_table_name}_raw;
        SQL
      end

      def load_operation
        <<-SQL
        insert into #{@base_table_name}(
          #{schema.keys.join(",\n")}
        )
        SELECT *
        from #{@base_table_name}_transformed;
        SQL
      end

      def inspect_csv_schema(source_file, csv_separator:)
        data = CSV.parse(File.open(source_file, "r").first(2).join, headers: true, col_sep: csv_separator)
        blank_cols = 0
        data.headers.inject({}) do |cols, col|
          col_name = if col.blank?
                       blank_cols += 1
                       "column_#{blank_cols}"
                     else
                       col.parameterize.underscore.to_sym

                     end
          cols.update(
            col_name => { original_name: col, type: "text" }
          )
        end
      end
    end
  end
end
