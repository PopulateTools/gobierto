# frozen_string_literal: true

module GobiertoCommon
  class TableInspectorQuery

    OPERATORS = {
      lt: "<",
      lteq: "<=",
      gt: ">",
      gteq: ">=",
      in: "IN",
      like: "ILIKE"
    }.with_indifferent_access

    COLUMN_TYPES = [
      :binary,
      :boolean,
      :date,
      :datetime,
      :decimal,
      :float,
      :integer,
      :primary_key,
      :string,
      :text,
      :time,
      :timestamp
    ].freeze

    attr_reader :relation

    def self.allowed_operators
      @allowed_operators ||= OPERATORS.keys << :eq
    end

    def initialize(options = {})
      @relation = options[:relation]
    end

    def filter(filters = {})
      filtered_query(
        filters,
        model_table[Arel.star]
      )
    end

    def stats(column, filters = {})
      data = OpenStruct.new

      data[:not_null_count] = aggregated_field(:count, column, filters)
      data[:distinct_count] = aggregated_field(:count, column, filters, distinct: true)
      if data[:not_null_count] < 4 || data[:distinct_count].to_f / data[:not_null_count] < 0.75
        data[:distribution] = distribution(column, filters, limit: 500)
      end

      if [:date, :datetime, :time, :integer, :decimal, :float].include? column.type
        data[:quartiles] = quantile(column, 4, filters)
        data[:min] = data[:quartiles]["q0"]
        data[:first_quartile] = data[:quartiles]["q1"]
        data[:median] = data[:quartiles]["q2"]
        data[:average] = aggregated_field(:avg, column, filters) if [:integer, :decimal, :float].include? column.type
        data[:third_quartile] = data[:quartiles]["q3"]
        data[:max] = data[:quartiles]["q4"]
        data[:histogram] = histogram(column, filters, data)
      end

      data.to_h
    end

    private

    def aggregated_field(aggregate_function, column, filters, distinct: false)
      aggregate_value = Arel::Nodes::SqlLiteral.new(
        "#{aggregate_function}(#{"distinct " if distinct}#{column.name}) as result"
      )

      filtered_query(
        filters,
        aggregate_value
      )[0]&.result
    end

    def quantile(column, buckets, filters)
      return unless buckets.positive?

      query_attributes = (0..buckets).map { |i| "percentile_disc(#{i.to_f / buckets}) within group(order by #{column.name}) as q#{i}" }.join(", ")

      filtered_query(
        filters,
        query_attributes
      )[0]&.attributes&.except("id")
    end

    def histogram(column, filters, stats, buckets = nil)
      return unless stats.min != stats.max && stats.not_null_count > 1

      buckets ||= Math.log(stats.not_null_count, 2).ceil + 1

      separations = [stats.not_null_count, buckets - 1, stats.distinct_count - 1].min

      interval_width = (stats.max - stats.min).to_f / (1 + separations)
      bucket_attributes = Arel::Nodes::SqlLiteral.new(
        if [:date, :datetime, :time, :timestamp].include?(column.type)
          "width_bucket(extract(epoch from #{column.name}), extract(epoch from '#{stats.min}'::timestamp), extract(epoch from '#{3.days.since(stats.max)}'::timestamp), #{separations}) as bucket, count(*)"
        else
          "width_bucket(#{column.name}, #{stats.min}, #{stats.max}, #{separations}) as bucket, count(*)"
        end
      )

      histogram_query = filtered_query(
        filters,
        bucket_attributes
      ).group(:bucket).order(bucket: :asc)

      (1..separations + 1).map do |bucket|
        boundaries(stats.min, bucket, interval_width, column.type).merge(
          bucket: bucket,
          count: histogram_query.find { |bin_data| bin_data.bucket == bucket }&.count || 0
        )
      end
    end

    def boundaries(min, bucket, width, column_type)
      values = {
        start: (min + width * (bucket - 1)),
        end: (min + width * bucket)
      }

      return values if [:date, :datetime, :time, :timestamp].include?(column_type) || width < 2

      values.tap do |val|
        val[:start] = values[:start].ceil
        val[:end] = values[:end].floor
      end
    end

    def distribution(column, filters, limit: nil)
      distribution_attributes = Arel::Nodes::SqlLiteral.new(
        "#{column.name} as value, count(*)"
      )

      distribution_query = filtered_query(
        filters,
        distribution_attributes
      ).group(:value).order(count: :desc).limit(limit)

      distribution_query.map do |value_data|
        { value: value_data.value,
          count: value_data.count }
      end
    end

    def filtered_query(filters, *select_attributes)
      filters.inject(relation.dup) do |global_result, (column, operations)|
        operations.inject(global_result) do |column_result, (operator, value)|
          column_result.where(filter_condition(column, operator, value))
        end
      end.select(*select_attributes)
    end

    def filter_condition(column, operator_sym, value)
      if (operator ||= OPERATORS[operator_sym]).present?
        filter_comparison_condition(column, operator, value)
      else
        filter_eq_condition(column, value)
      end
    end

    def filter_comparison_condition(column, operator, value)
      value = if operator == "IN" && value.is_a?(Array)
                "(#{value.map { |v| "'#{v.inspect}'" }.join(", ")})"
              else
                "'#{value}'"
              end

      Arel::Nodes::SqlLiteral.new(
        "#{column.name} #{operator} #{value}"
      )
    end

    def filter_eq_condition(column, value)
      operator = "="
      Arel::Nodes::SqlLiteral.new(
        "#{column.name} #{operator} #{value}"
      )
    end

    def model_table
      @model_table ||= relation.model.arel_table
    end

  end
end
