# frozen_string_literal: true

module GobiertoBudgets
  module SearchEngineConfiguration
    class Invoice
      def self.all_indices
        [index]
      end

      def self.index
        GobiertoData::GobiertoBudgets::ES_INDEX_INVOICES
      end

      def self.type
        GobiertoData::GobiertoBudgets::INVOICE_TYPE
      end
    end
  end
end
