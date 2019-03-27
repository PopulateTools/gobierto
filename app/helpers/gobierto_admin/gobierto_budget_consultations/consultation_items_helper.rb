# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoBudgetConsultations
    module ConsultationItemsHelper
      def consultation_item_budget_lines_options(budget_lines)
        budget_lines.map do |budget_line|
          {
            label: consultation_item_budget_line_label_for(budget_line), # Required by the autocomplete control
            value: budget_line[:name], # Required by the autocomplete control
            id: budget_line[:id],
            name: budget_line[:name],
            amount: budget_line[:amount]
          }
        end
      end

      def consultation_item_budget_line_label_for(budget_line)
        "#{budget_line[:name]}, #{budget_line[:date]} (#{number_to_currency(budget_line[:amount])})"
      end
    end
  end
end
