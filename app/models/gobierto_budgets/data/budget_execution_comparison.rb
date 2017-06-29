module GobiertoBudgets
  module Data
    class BudgetExecutionComparison
      def self.extract_lines(options)
        builder = new(options)
        builder.calculate_lines
      end

      def initialize(options)
        @year = options[:year]
        @kind = options[:kind]
        @area = options[:area]
        @place = INE::Places::Place.find(options[:ine_code])
      end

      attr_reader :year, :kind, :area, :place

      def calculate_lines
        lines = []
        # Calculate level 1

        base_conditions = {place: place, kind: kind, area_name: area, level: 1, year: year}
        budget_lines_forecast = GobiertoBudgets::BudgetLine.where(base_conditions.merge(index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast)).all
        budget_lines_execution = GobiertoBudgets::BudgetLine.where(base_conditions.merge(index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed)).all

        budget_lines_forecast.each do |budget_line_forecast|
          budget_line_execution = budget_lines_execution.detect{ |bl| bl.code == budget_line_forecast.code }
          next if budget_line_execution.nil?

          category = kind == GobiertoBudgets::BudgetLine::EXPENSE ? "expense_" : "income_"
          category += area
          pct_executed = ((budget_line_execution.amount / budget_line_forecast.amount) * 100).round(2)
          lines.push({
            "parent_id": budget_line_forecast.code,
            "id": budget_line_forecast.code,
            "category": category,
            "name_es": budget_line_forecast.name("es"),
            "name_ca": budget_line_forecast.name("ca"),
            "level": budget_line_forecast.level,
            "budget": budget_line_forecast.amount,
            "executed": budget_line_execution.amount,
            "pct_executed": pct_executed,
          })
        end

        base_conditions = {place: place, kind: kind, area_name: area, level: 2, year: year}
        budget_lines_forecast = GobiertoBudgets::BudgetLine.where(base_conditions.merge(index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast)).all
        budget_lines_execution = GobiertoBudgets::BudgetLine.where(base_conditions.merge(index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed)).all

        budget_lines_forecast.each do |budget_line_forecast|
          budget_line_execution = budget_lines_execution.detect{ |bl| bl.code == budget_line_forecast.code }
          next if budget_line_execution.nil?

          category = kind == GobiertoBudgets::BudgetLine::EXPENSE ? "expense_" : "income_"
          category += area
          pct_executed = ((budget_line_execution.amount / budget_line_forecast.amount) * 100).round(2)
          lines.push({
            "parent_id": budget_line_forecast.parent_code,
            "id": budget_line_forecast.code,
            "category": category,
            "name_es": budget_line_forecast.name("es"),
            "name_ca": budget_line_forecast.name("ca"),
            "level": budget_line_forecast.level,
            "budget": budget_line_forecast.amount,
            "executed": budget_line_execution.amount,
            "pct_executed": pct_executed,
          })
        end

        lines
      end
    end
  end
end
