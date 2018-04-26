# frozen_string_literal: true

module GobiertoBudgets
  class SearchEngineConfiguration
    class Year
      def self.last(force = false)
        default_year = 2017
        return default_year if force
        current_site = GobiertoCore::CurrentScope.current_site
        return default_year if current_site.nil?
        Rails.cache.fetch("budgets/data/year/last/#{ current_site.try(:id) || "global" }") do
          get_last_year_with_data(default_year, current_site)
        end
      end

      def self.get_last_year_with_data(default_year, current_site)
        Date.today.year.downto(first) do |year|
          next unless GobiertoBudgets::BudgetLine.any_data?(site: GobiertoCore::CurrentScope.current_site, index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, year: year)
          if year == Date.today.year && (GobiertoCore::CurrentScope.current_site.gobierto_budgets_settings && !GobiertoCore::CurrentScope.current_site.gobierto_budgets_settings.settings["budgets_elaboration"])
            return year
          end
        end
        return default_year
      end

      def self.first
        2010
      end

      def self.all
        @all ||= (first..last).to_a.reverse
      end
    end

    class BudgetCategories
      def self.index
        "tbi-collections"
      end

      def self.type
        if I18n.locale == :ca
          "c-categorias-presupuestos-municipales-cat"
        else
          "c-categorias-presupuestos-municipales"
        end
      end
    end

    class BudgetLine
      def self.all_indices
        [index_forecast, index_executed, index_executed_series, index_forecast_updated]
      end

      def self.index_forecast
        "budgets-forecast-v3"
      end

      def self.index_executed
        "budgets-execution-v3"
      end

      def self.index_executed_series
        "gobierto-budgets-execution-series-v1"
      end

      def self.index_forecast_updated
        "budgets-forecast-updated-v1"
      end
    end

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

    class Data
      def self.index
        "data"
      end

      def self.type_population
        "population"
      end

      def self.type_debt
        "debt"
      end
    end
  end
end
