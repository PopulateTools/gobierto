module GobiertoBudgetConsultations
  module ConsultationsHelper
    def budget_amount_to_human(budget_amount)
      number_to_human(budget_amount, precision: 3, units: { million: "M" })
    end
  end
end
