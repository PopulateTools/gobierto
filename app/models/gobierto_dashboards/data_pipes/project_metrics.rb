# frozen_string_literal: true

require_relative "../../gobierto_dashboards"

module GobiertoDashboards
  module DataPipes
    class ProjectMetrics < Base
      delegate :safe_parameterize, to: :class

      def output_data
        {
          data: indicator_names_disambiguation(custom_field_records.map { |record| indicators(record) }.compact.flatten)
        }.to_json
      end

      def self.safe_parameterize(text)
        ActiveSupport::Inflector.transliterate(text).parameterize
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
        published_version = record.item.published_version
        return unless published_version.present?

        published_value = ::GobiertoCommon::CustomFieldFunctions::Indicator.new(record, version: published_version).value
        return unless published_value.is_a? Array

        published_project = ::GobiertoPlans::ProjectDecorator.new(record.item, opts: { plan: @context.resource }).at_current_version
        project = published_project.to_global_id.to_s
        project_name = published_project.name
        grouped_values(published_value).map do |key, values|
          {
            name: values.first["indicator"].strip.squeeze(" "),
            id: key,
            project: project,
            project_name: project_name,
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
          safe_parameterize(row["indicator"])
        end
      end
    end
  end
end
