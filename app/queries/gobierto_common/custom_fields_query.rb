# frozen_string_literal: true

module GobiertoCommon
  class CustomFieldsQuery

    OPERATORS = {
      lt: "<",
      lteq: "<=",
      gt: ">",
      gteq: ">=",
      in: "IN",
      like: "ILIKE"
    }.with_indifferent_access

    CAST_FUNCTIONS = {
      numeric: "::text::numeric",
      date: "::text::date",
      default: "::text"
    }.with_indifferent_access

    attr_writer :custom_fields
    attr_reader :relation

    def self.allowed_operators
      @allowed_operators ||= OPERATORS.keys << :eq
    end

    def initialize(options = {})
      @relation = options[:relation]
      @instance = options[:instance]
      @class = options[:class] || @relation.model
    end

    def filter(filters = {})
      filtered_query(
        filters,
        instance_join_manager_for_filters(filters),
        model_table[Arel.star]
      )
    end

    def filter_with_fields_extraction(filters = {})
      filtered_query(
        filters,
        instance_join_manager_with_all_fields,
        model_table[Arel.star],
        *custom_fields_attributes
      )
    end

    def custom_fields
      @custom_fields ||= CustomField.where(instance: @instance).for_class(@class)
    end

    private

    def filtered_query(filters, join_manager, *select_attributes)
      filters.inject(join_manager) do |global_result, (custom_field, operations)|
        operations.inject(global_result) do |custom_field_result, (operator, value)|
          custom_field_result.where(filter_condition(custom_field, operator, value))
        end
      end.select(*select_attributes)
    end

    def custom_fields_attributes
      custom_fields.map do |custom_field|
        Arel::Nodes::NamedFunction.new(
          "jsonb_extract_path",
          [custom_fields_subqueries[custom_field.id][:payload], Arel::Nodes::SqlLiteral.new("'#{custom_field.uid}'")],
          "custom_field_value_#{custom_field.id}"
        )
      end
    end

    def subquery_join(custom_field)
      subquery = custom_fields_subqueries[custom_field.id]
      model_table.join(subquery, Arel::Nodes::OuterJoin).on(
        subquery[:item_id].eq(model_table[:id]).and(
          subquery[:item_type].eq(relation.model.name)
        )
      )
    end

    def subquery(custom_field)
      custom_field_records_table.project(
        custom_field_records_table[:item_id],
        custom_field_records_table[:item_type],
        custom_field_records_table[:payload]
      ).from(
        custom_field_records_table
      ).join(custom_fields_table).on(
        custom_fields_table[:id].eq(custom_field_records_table[:custom_field_id])
      ).where(custom_fields_table[:id].eq(custom_field.id)).as(
        "\"#{custom_field.id}_#{custom_fields_table.name}\""
      )
    end

    def instance_join_manager_with_all_fields
      @instance_join_manager_with_all_fields ||= begin
                                                   custom_fields.inject(relation.dup) do |rel, custom_field|
                                                     rel.joins(subquery_join(custom_field).join_sources)
                                                   end
                                                 end
    end

    def instance_join_manager_for_filters(filters = {})
      custom_fields.where(id: filters.keys.map(&:id)).inject(relation.dup) do |rel, custom_field|
        rel.joins(subquery_join(custom_field).join_sources)
      end
    end

    def custom_fields_subqueries
      @custom_fields_subqueries ||= custom_fields.inject({}) do |subqueries, custom_field|
        subqueries.update(
          custom_field.id => subquery(custom_field)
        )
      end
    end

    def filter_condition(custom_field, operator_sym, value)
      if (operator ||= OPERATORS[operator_sym]).present?
        filter_comparison_condition(custom_field, operator, value)
      else
        filter_eq_condition(custom_field, value)
      end
    end

    def filter_comparison_condition(custom_field, operator, value)
      value = if operator == "IN" && value.is_a?(Array)
                "(#{value.map { |v| "'#{v.inspect}'" }.join(", ")})"
              else
                "'#{value}'"
              end

      value_function = Arel::Nodes::NamedFunction.new(
        "jsonb_extract_path",
        [custom_fields_subqueries[custom_field.id][:payload], Arel::Nodes::SqlLiteral.new("'#{custom_field.uid}'")]
      )

      Arel::Nodes::SqlLiteral.new(
        "#{value_function.to_sql}#{cast_function(custom_field)} #{operator} #{value}"
      )
    end

    def filter_eq_condition(custom_field, value)
      Arel::Nodes::InfixOperation.new(
        "@>",
        custom_fields_subqueries[custom_field.id][:payload],
        Arel::Nodes::SqlLiteral.new("'#{{ custom_field.uid => value }.to_json}'")
      )
    end

    def model_table
      @model_table ||= relation.model.arel_table
    end

    def custom_fields_table
      GobiertoCommon::CustomField.arel_table
    end

    def custom_field_records_table
      GobiertoCommon::CustomFieldRecord.arel_table
    end

    def cast_function(custom_field)
      CAST_FUNCTIONS.fetch(custom_field.field_type, CAST_FUNCTIONS[:default])
    end

  end
end
