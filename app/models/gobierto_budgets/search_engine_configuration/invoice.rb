# frozen_string_literal: true

module GobiertoBudgets
  module SearchEngineConfiguration
    class Invoice
      def self.all_indices
        [index]
      end

      def self.index
        GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_INVOICES
      end

      def self.type
        GobiertoBudgetsData::GobiertoBudgets::INVOICE_TYPE
      end
    end
  end
end
