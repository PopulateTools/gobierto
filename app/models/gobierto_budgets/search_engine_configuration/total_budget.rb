# frozen_string_literal: true

module GobiertoBudgets
  module SearchEngineConfiguration
    class TotalBudget

      def self.all_indices
        [index_forecast, index_executed, index_forecast_updated]
      end

      def self.index_forecast
        "budgets-forecast-v3"
      end

      def self.index_executed
        "budgets-execution-v3"
      end

      def self.index_forecast_updated
        "budgets-forecast-updated-v1"
      end

      def self.type
        "total-budget"
      end

    end
  end
end
