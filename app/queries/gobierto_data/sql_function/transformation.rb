# frozen_string_literal: true

module GobiertoData
  module SqlFunction
    class Transformation

      attr_reader :function_type, :function_name, :function

      SQL_FUNCTIONS = {
        integer: {
          input_type: "text",
          output_type: "integer",
          sql: "select (nullif(trim($1), '#null_value')::integer);",
          optional_params: { null_value: "" }
        },
        numeric: {
          input_type: "text",
          output_type: "numeric",
          sql: "select (nullif(trim($1), '#null_value')::numeric);",
          optional_params: { null_value: "" }
        },
        numeric_with_custom_decimal_separator: {
          input_type: "text",
          output_type: "numeric",
          sql: "select (replace(nullif(trim($1), '#null_value'), '#decimal_separator', '.')::numeric);",
          optional_params: { null_value: "", decimal_separator: "," }
        },
        text: {
          input_type: "text",
          output_type: "text",
          sql: "select (nullif(trim($1), '#null_value')::text);",
          optional_params: { null_value: "" }
        },
        date: {
          input_type: "text",
          output_type: "date",
          sql: "select (to_date(nullif(trim($1), '#null_value'), '#date_format'));",
          optional_params: { date_format: "DD-MON-YYY", null_value: "" }
        },
        boolean: {
          input_type: "text",
          output_type: "boolean",
          sql: "select (case\n  when trim($1) = '#true_value' then true\n  when trim($1) = '#false_value' then false\n  else NULL\nend)",
          optional_params: { false_value: "0", true_value: "1" }
        }
      }.freeze

      def initialize(opts = {})
        @function_type = opts.fetch(:function, :text).to_sym
        @id = opts.fetch(:id, "generic")
        @function_name = "#{function_type}_#{@id}_transformation"
        @function = SQL_FUNCTIONS[function_type]
        default_optional_params = @function.fetch(:optional_params, {})
        @optional_params = default_optional_params.merge(opts.fetch(:optional_params, {}).slice(*default_optional_params.keys))
      end

      def output_type
        function[:output_type]
      end

      def function_definition
        return unless function.present?

        <<-SQL
        CREATE FUNCTION #{function_name}(#{function[:input_type]}) RETURNS #{function[:output_type]} AS $$
        #{ @optional_params.inject(function[:sql]) { |sql, (param, value)| sql.gsub("##{param}", value) }}
        $$ LANGUAGE SQL;
        SQL
      end

      def function_drop
        return unless function.present?

        "DROP FUNCTION IF EXISTS #{function_name}(#{function[:input_type]});"
      end

      def function_call(attribute)
        "#{function_name}(#{attribute})"
      end

    end
  end
end
