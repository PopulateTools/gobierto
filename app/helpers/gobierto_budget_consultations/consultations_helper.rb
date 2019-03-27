# frozen_string_literal: true

module GobiertoBudgetConsultations
  module ConsultationsHelper
    def budget_amount_to_human(budget_amount)
      number_to_currency(budget_amount, :precision => (budget_amount.round == budget_amount) ? 0 : 2)
    end
  end
end
