# frozen_string_literal: true

module GobiertoBudgets
  module Data
    class BudgetExecutionComparison
      def self.extract_lines(options)
        builder = new(options)
        builder.calculate_lines
      end

      def initialize(options)
        @site = options[:site]
        @year = options[:year]
        @kind = options[:kind]
        @area = options[:area]
      end

      attr_reader :site, :year, :kind, :area

      def calculate_lines
        base_conditions = { site: site, kind: kind, area_name: area, level: 1, year: year }
        lines_level_1 = calculate_lines_with_conditions(base_conditions)

        base_conditions = { site: site, kind: kind, area_name: area, level: 2, year: year }
        lines_level_2 = calculate_lines_with_conditions(base_conditions)

        lines_level_1 + lines_level_2
      end

      private

      def calculate_lines_with_conditions(base_conditions)
        lines = []
        budget_lines_forecast_updated = GobiertoBudgets::BudgetLine.all(where: base_conditions.merge(index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast_updated))
        budget_lines_forecast = GobiertoBudgets::BudgetLine.all(where: base_conditions.merge(index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast))
        budget_lines_execution = GobiertoBudgets::BudgetLine.all(where: base_conditions.merge(index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed))

        budget_lines_forecast.each do |budget_line_forecast|
          budget_line_execution = budget_lines_execution.detect { |bl| bl.code == budget_line_forecast.code }
          budget_line_forecast_updated = budget_lines_forecast_updated.detect { |bl| bl.code == budget_line_forecast.code }
          execution_amount = budget_line_execution.try(:amount) || 0
          forecast_amount = budget_line_forecast_updated ? budget_line_forecast_updated.amount : budget_line_forecast.amount
          next if forecast_amount == 0 || forecast_amount.nil?

          category = kind == GobiertoBudgets::BudgetLine::EXPENSE ? "expense_" : "income_"
          category += area
          pct_executed = ((execution_amount / forecast_amount) * 100).round(2)

          lines.push(
            "parent_id": budget_line_forecast.level == 1 ? budget_line_forecast.code : budget_line_forecast.parent_code,
            "id": budget_line_forecast.code,
            "category": category,
            "name_es": budget_line_forecast.name("es"),
            "name_ca": budget_line_forecast.name("ca"),
            "level": budget_line_forecast.level,
            "budget": budget_line_forecast.amount,
            "budget_updated": budget_line_forecast_updated.try(:amount),
            "executed": execution_amount,
            "pct_executed": pct_executed
          )
        end

        lines
      end
    end
  end
end
