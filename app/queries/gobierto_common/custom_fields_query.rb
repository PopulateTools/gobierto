# frozen_string_literal: true

module GobiertoCommon
  class CustomFieldsQuery

    attr_writer :custom_fields
    attr_reader :relation

    def initialize(options = {})
      @relation = options[:relation]
      @instance = options[:instance]
    end

    def filter(filters = {})
      filters.inject(instance_join_manager) do |result, (custom_field, value)|
        result.where(filter_condition(custom_field, value))
      end.select(
        model_table[Arel.star],
        *custom_fields_attributes
      )
    end

    def custom_fields
      @custom_fields ||= CustomField.where(instance: @instance)
    end

    private

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

    def instance_join_manager
      @instance_join_manager ||= begin
                                   base_relation = relation
                                   CustomField.where(instance: @instance).each do |custom_field|
                                     base_relation = base_relation.joins(subquery_join(custom_field).join_sources)
                                   end
                                   base_relation
                                 end
    end

    def custom_fields_subqueries
      @custom_fields_subqueries ||= custom_fields.inject({}) do |subqueries, custom_field|
        subqueries.update(
          custom_field.id => subquery(custom_field)
        )
      end
    end

    def filter_condition(custom_field, value)
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

  end
end
