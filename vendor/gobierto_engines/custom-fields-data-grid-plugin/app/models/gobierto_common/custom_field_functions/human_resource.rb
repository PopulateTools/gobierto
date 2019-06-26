# frozen_string_literal: true

module GobiertoCommon::CustomFieldFunctions
  class HumanResource < Base
    def progress(options = {})
      date = options[:date] || Date.current

      progress_percentages(date).instance_eval do
        return nil if blank?

        sum / size.to_f
      end
    end

    def cost(options = {})
      percentages = progress_percentages(options[:date] || Date.current)

      percentages.each_with_index.inject(0) do |total, (percentage, index)|
        total + percentage * data[index].cost
      end / percentages.size.to_f
    end

    private

    def data
      @data ||= begin
                  resources = value.dig("human_resources") || []

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

          (date - resource.start_date).to_f / (resource.end_date - resource.start_date).to_f
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
