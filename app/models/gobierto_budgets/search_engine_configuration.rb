module GobiertoBudgets
  class SearchEngineConfiguration
    class Year
      def self.last
        Date.today.year.downto(first) do |year|
          if GobiertoCore::CurrentScope.current_site.present?
            if GobiertoBudgets::BudgetLine.any_data?(site: GobiertoCore::CurrentScope.current_site, index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, year: year)
              if year == Date.today.year && (GobiertoCore::CurrentScope.current_site.gobierto_budgets_settings && !GobiertoCore::CurrentScope.current_site.gobierto_budgets_settings.settings["budgets_elaboration"])
                return year
              end
            end
          end
        end
        2017
      end

      def self.first; 2010 end
      def self.all
        @all ||= (first..last).to_a.reverse
      end
    end

    class BudgetCategories
      def self.index; 'tbi-collections' end
      def self.type
        if I18n.locale == :ca
          'c-categorias-presupuestos-municipales-cat'
        else
          'c-categorias-presupuestos-municipales'
        end
      end
    end

    class BudgetLine
      def self.index_forecast; 'budgets-forecast-v3' end
      def self.index_executed; 'budgets-execution-v3' end
      def self.index_executed_series; 'gobierto-budgets-execution-series-v1' end
      def self.index_forecast_updated; 'budgets-forecast-updated-v1' end
    end

    class TotalBudget
      def self.all_indices
        [index_forecast, index_executed, index_forecast_updated]
      end

      def self.index_forecast; 'budgets-forecast-v3' end
      def self.index_executed; 'budgets-execution-v3' end
      def self.index_forecast_updated; 'budgets-forecast-updated-v1' end
      def self.type; 'total-budget' end
    end

    class Data
      def self.index; 'data' end
      def self.type_population; 'population' end
      def self.type_debt; 'debt' end
    end

  end
end
