# frozen_string_literal: true

module GobiertoCommon::CustomFieldFunctions
  class Budget < Base
    def progress(_options = {})
      progress_percentages.instance_eval do
        return nil if blank?

        sum / size.to_f
      end
    end

    def planned_cost
      @planned_cost ||= data.map do |line|
        next unless line.weight && line.forecast

        line.forecast * line.weight
      end.compact.sum
    end

    def executed_cost
      @executed_cost ||= data.map do |line|
        next unless line.weight && line.execution

        line.execution * line.weight
      end.compact.sum
    end

    private

    def data
      @data ||= begin
                  lines = value.dig("budget_lines") || []

                  lines.map do |line|
                    line_details = GobiertoBudgets::BudgetLine.find_details(id: line["id"] + "/#{line["area"]}")

                    Hashie::Mash.new(
                      forecast: line_details.forecast.updated_amount || line_details.forecast.original_amount,
                      execution: line_details.execution.amount,
                      weight: numeric?(line["weight"]) ? line["weight"].to_f / 100.0 : nil
                    )
                  rescue GobiertoBudgets::BudgetLine::RecordNotFound
                  end.compact
                end
    end

    def numeric?(data)
      Float(data).present?
    rescue ArgumentError, TypeError
      false
    end

    def progress_percentages
      @progress_percentages ||= data.map do |line|
        next 0 unless line.forecast.present?

        (line.execution || 0) / line.forecast.to_f
      end.compact
    end
  end
end
