# frozen_string_literal: true

require_relative "../../gobierto_dashboards"

module GobiertoDashboards
  module DataPipes
    class ProjectMetrics < Base
      def output_data
        {
          data: indicator_names_disambiguation(custom_field_records.map { |record| indicators(record) }.compact.flatten)
        }.to_json
      end

      private

      def custom_fields
        site.custom_fields.find_by(**custom_field_condition)
      end

      def custom_field_records
        site.custom_field_records.where(custom_fields: custom_field_condition)
      end

      def custom_field_condition
        @custom_field_condition ||= { instance: @context.resource, uid: "project-metrics" }
      end

      def indicators(record)
        return unless record.value.is_a? Array

        grouped_values(record.value).map do |key, values|
          {
            name: values.first["indicator"].strip.squeeze(" "),
            id: key,
            project: record.item.to_global_id.to_s,
            project_name: record.item.name,
            values: values.map { |value| value.except("indicator") }
          }
        end
      end

      def indicator_names_disambiguation(data)
        names = data.map { |indicator| indicator[:name] }
        duplicated_names = names.group_by(&:itself).select { |_, v| v.size > 1 }.map(&:first)

        data.map do |indicator|
          next indicator unless duplicated_names.include? indicator[:name]

          indicator.merge(name: "#{indicator[:project_name]} - #{indicator[:name]}")
        end
      end

      def grouped_values(values)
        values.group_by do |row|
          ActiveSupport::Inflector.transliterate(row["indicator"]).parameterize
        end
      end
    end
  end
end
