# frozen_string_literal: true

require_relative "../../gobierto_dashboards"

module GobiertoDashboards
  module DataPipes
    class ProjectMetrics < Base
      def output_data
        ActiveModelSerializers::SerializableResource.new(
          custom_field_records,
          each_serializer: GobiertoDashboards::CustomFieldRecordDataSerializer
        ).to_json
      end

      private

      def custom_fields
        site.custom_fields.where(instance: @context.resource)
      end

      def custom_field_records
        site.custom_field_records.where(custom_fields: { instance: @context.resource })
      end
    end
  end
end
