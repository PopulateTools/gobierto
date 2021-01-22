# frozen_string_literal: true

module GobiertoDashboards
  class DashboardDataSerializer < BaseSerializer
    attribute :values

    def values
      object.custom_field_records.map do |record|
        {
          name: record.custom_field.uid,
          item: record.item.to_global_id.to_s,
          values: record.value
        }
      end
    end
  end
end
