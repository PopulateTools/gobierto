# frozen_string_literal: true

module GobiertoDashboards
  class CustomFieldRecordDataSerializer < BaseSerializer
    attribute :name do
      object.custom_field.uid
    end

    attribute :item do
      next unless object.item.present?

      object.item.to_global_id.to_s
    end

    attribute :values do
      object.value
    end
  end
end
