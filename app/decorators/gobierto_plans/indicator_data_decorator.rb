# frozen_string_literal: true

module GobiertoPlans
  class IndicatorDataDecorator < BaseDecorator
    def initialize(plan)
      @collection = plan.indicators
    end

    def csv_header
      %w(class_name name_translations options uid instance_type record_item_type record_payload)
    end

    def csv_row(object)
      [
        object.custom_field.class_name,
        object.custom_field.name_translations,
        object.custom_field.options,
        object.custom_field.uid,
        object.custom_field.instance_type,
        object[:item_type],
        object[:payload]
      ]
    end

    def csv
      CSV.generate do |csv|
        csv << csv_header
        @collection.each do |item|
          csv << csv_row(item)
        end
      end.force_encoding('utf-8')
    end

  end
end
