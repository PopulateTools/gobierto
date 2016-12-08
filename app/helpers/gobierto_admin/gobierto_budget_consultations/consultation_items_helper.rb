module GobiertoAdmin
  module GobiertoBudgetConsultations
    module ConsultationItemsHelper
      def consultation_item_budget_lines_options_for_select(budget_lines, budget_line_id)
        budget_line_options = budget_lines.map do |budget_line|
          [
            "#{budget_line[:name]}, #{budget_line[:date]} (#{number_to_currency(budget_line[:amount])})",
            budget_line[:id],
            data: {
              name: budget_line[:name],
              amount: budget_line[:amount]
            }
          ]
        end

        options_for_select(budget_line_options, budget_line_id)
      end
    end
  end
end
