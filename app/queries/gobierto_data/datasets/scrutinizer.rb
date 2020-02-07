# frozen_string_literal: true

module GobiertoData
  module Datasets
    class Scrutinizer

      SORTABLE_TYPES = [
        :date,
        :datetime,
        :time,
        :timestamp,
        :integer,
        :decimal,
        :float
      ].freeze

      attr_reader :dataset, :relation

      def initialize(options = {})
        @dataset = options[:dataset]
        @relation = dataset.rails_model
      end

      def stats(column)
        data = OpenStruct.new

        data[:not_null_count] = aggregated_field(:count, column)
        data[:distinct_count] = aggregated_field(:count, column, distinct: true)
        if data[:not_null_count] < 4 || data[:distinct_count].to_f / data[:not_null_count] < 0.75
          data[:distribution] = distribution(column, limit: 100)
        end

        if sortable? column
          data[:quartiles] = quantile(column, 4)
          data[:min] = data[:quartiles]["q0"]
          data[:first_quartile] = data[:quartiles]["q1"]
          data[:median] = data[:quartiles]["q2"]
          data[:average] = aggregated_field(:avg, column) if [:integer, :decimal, :float].include? column.type
          data[:third_quartile] = data[:quartiles]["q3"]
          data[:max] = data[:quartiles]["q4"]
          data[:histogram] = histogram(column, data)
        end

        data.to_h
      end

      private

      def sortable?(column)
        SORTABLE_TYPES.include? column.type
      end

      def aggregated_field(aggregate_function, column, distinct: false)
        aggregate_value = Arel::Nodes::SqlLiteral.new(
          "#{aggregate_function}(#{"DISTINCT " if distinct}\"#{column.name}\") AS RESULT"
        )

        query_select(
          aggregate_value
        )[0]&.result
      end

      def quantile(column, buckets)
        return unless buckets.positive?

        query_attributes = (0..buckets).map { |i| "PERCENTILE_DISC(#{i.to_f / buckets}) WITHIN GROUP(ORDER BY \"#{column.name}\") AS q#{i}" }.join(", ")

        query_select(
          query_attributes
        )[0]&.attributes&.except("id")
      end

      def histogram(column, stats, buckets = nil)
        return unless stats.min != stats.max && stats.not_null_count > 1

        buckets ||= Math.log(stats.not_null_count, 2).ceil + 1

        bucket_attributes = Arel::Nodes::SqlLiteral.new(
          if [:date, :datetime, :time, :timestamp].include?(column.type)
            transform_operator = column.type == :time ? "TIME" : "TIMESTAMP"
            <<-TEXT
            WIDTH_BUCKET(
              EXTRACT(EPOCH FROM \"#{column.name}\"),
              EXTRACT(EPOCH FROM '#{stats.min}'::#{transform_operator}),
              EXTRACT(EPOCH FROM '#{stats.max}'::#{transform_operator}),
              #{buckets}
            ) AS bucket, COUNT(*)
            TEXT
          else
            "WIDTH_BUCKET(\"#{column.name}\", #{stats.min}, #{stats.max}, #{buckets}) AS bucket, COUNT(*)"
          end
        )

        histogram_query = query_select(
          bucket_attributes
        ).where.not(column.name => nil).group(:bucket).order(bucket: :asc)

        interval_width = (stats.max - stats.min).to_f / buckets

        (1..buckets).map do |bucket|
          count = if bucket == buckets
                    histogram_query.select { |bin_data| bin_data.bucket >= bucket }.map(&:count).sum
                  else
                    histogram_query.find { |bin_data| bin_data.bucket == bucket }&.count || 0
                  end
          boundaries(stats.min, bucket, interval_width, column.type).merge(
            bucket: bucket,
            count: count
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

      def distribution(column, limit: nil)
        distribution_attributes = Arel::Nodes::SqlLiteral.new(
          "\"#{column.name}\" AS value, COUNT(*)"
        )

        distribution_query = query_select(
          distribution_attributes
        ).group(:value).order(count: :desc).limit(limit)

        distribution_query.map do |value_data|
          { value: value_data.value,
            count: value_data.count }
        end
      end

      def query_select(*select_attributes)
        relation.select(*select_attributes)
      end

    end
  end
end
