# frozen_string_literal: true

module GobiertoBudgets
  module SearchEngineConfiguration
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
  end
end
