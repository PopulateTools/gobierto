# frozen_string_literal: true

module GobiertoPlans
  class IndicatorDataDecorator < BaseDecorator

    attr_reader :plan, :collection

    def initialize(plan)
      @plan = plan
      @collection = plan.indicators
      @columns = 0
    end

    def csv
      lines = []
      CSV.generate do |csv|
        collection.each do |item|
          lines.concat(csv_row(item))
        end
        # need iterate again because header length is dynamic
        csv << csv_header
        lines.each do |line|
          # TODO: add extra commas ?
          csv << line
        end
      end.force_encoding('utf-8')
    end

    private

    def csv_header
      header = %w(Node.Title Node.external_id custom_field)
      1.upto(@columns) do |index|
        header << "col_#{index}"
      end
      header
    end

    def csv_row(object)
      current_columns = object.payload[object.custom_field.uid.to_s].first&.size
      values = object.payload[object.custom_field.uid.to_s].map(&:values)
      @columns = current_columns if current_columns > @columns

      values = object.payload[object.custom_field.uid.to_s].map(&:values)
      values.map do |value|
        [
          plan.title_translations["en"],
          object.item.external_id,        # N+1 because it is polymorphic
          object.custom_field.uid
        ].concat(value)
      end

    end

  end
end
