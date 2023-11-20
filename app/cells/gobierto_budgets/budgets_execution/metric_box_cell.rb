# frozen_string_literal: true

module GobiertoBudgets
  module BudgetsExecution
    class MetricBoxCell

      attr_accessor :expense_type, :execution_summary

      def initialize(params = {})
        self.expense_type = params[:expense_type].to_s
        self.execution_summary = params[:execution_summary]
      end

      def title
        I18n.t("gobierto_budgets.budgets_execution.index.metric.execution.#{expense_type}_title")
      end

      def value
        execution_summary.send("#{expense_type}_execution_percentage".to_sym)
      end

      def explanation_percentage
        execution_summary.send("#{expense_type}_previous_execution_percentage".to_sym)
      end

      def explanation_text
        if explanation_percentage
          I18n.t(
            "gobierto_budgets.budgets_execution.index.metric.execution.previous_execution_message",
            year: execution_summary.previous_year,
            percentage: explanation_percentage
          )
        end
      end

      def rows
        rows = []

        if rows_data.budgeted_updated
          rows << { text: I18n.t("gobierto_budgets.budgets_execution.index.#{expense_type}_planned"), value: rows_data.budgeted_updated }
          rows << { text: I18n.t("gobierto_budgets.budgets_execution.index.initial_estimate"), value: rows_data.budgeted }
        else
          rows << { text: I18n.t("gobierto_budgets.budgets_execution.index.#{expense_type}_planned"), value: rows_data.budgeted }
        end

        rows << { text: I18n.t("gobierto_budgets.budgets_execution.index.#{expense_type}_executed"), value: rows_data.execution }
        rows
      end

      private

      def rows_data
        execution_summary.send("last_#{expense_type}".to_sym)
      end

    end
  end
end
