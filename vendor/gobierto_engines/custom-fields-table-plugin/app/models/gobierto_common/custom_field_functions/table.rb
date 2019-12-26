# frozen_string_literal: true

module GobiertoCommon::CustomFieldFunctions
  class Table < Base

    def progress(options = {})
      date = options[:date] || Date.current

      result = progress_percentages(date).instance_eval do
        return nil if blank?

        sum / size.to_f
      end

      result.nan? ? nil : result
    end

    def executed_cost(options = {})
      percentages = progress_percentages(options[:date] || Date.current)

      percentages.each_with_index.inject(0) do |total, (percentage, index)|
        total + percentage * data[index].cost
      end
    end

    def planned_cost(_options = {})
      data.map(&:cost).compact.sum
    end

    private

    def data
      @data ||= begin
                  resources = value.is_a?(Array) ? value : value.dig(custom_field.uid) || []

                  resources.map do |resource|
                    OpenStruct.new(
                      start_date: parse_date(resource["start_date"]),
                      end_date: parse_date(resource["end_date"]),
                      cost: resource["cost"].to_f
                    )
                  end
                end
    end

    def progress_percentages(date)
      data.map do |resource|
        if resource.start_date && date < resource.start_date
          0.0
        elsif resource.end_date && date > resource.end_date
          1.0
        else
          next unless resource.start_date.present? && resource.end_date.present?

          (date - resource.start_date).to_f / (resource.end_date - resource.start_date)
        end
      end.compact
    end

    def parse_date(date, fallback = nil)
      return unless date

      Date.parse(date)
    rescue ArgumentError
      fallback
    end
  end
end
