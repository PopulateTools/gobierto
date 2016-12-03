module GobiertoAdmin
  module GobiertoBudgetConsultations
    module ConsultationItemsHelper
      def consultation_item_budget_lines_options_for_select(budget_lines)
        budget_line_options = budget_lines.map do |budget_line|
          [budget_line.name, budget_line.id, data: { amount: budget_line.amount }]
        end

        options_for_select(budget_line_options)
      end
    end
  end
end
