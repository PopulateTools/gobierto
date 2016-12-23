module GobiertoBudgets
  class SearchEngineConfiguration
    class Year
      def self.last; 2016 end
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
    end

    class TotalBudget
      def self.index_forecast; 'budgets-forecast-v3' end
      def self.index_executed; 'budgets-execution-v3' end
      def self.type; 'total-budget' end
    end

    class Data
      def self.index; 'data' end
      def self.type_population; 'population' end
      def self.type_debt; 'debt' end
    end

  end
end
