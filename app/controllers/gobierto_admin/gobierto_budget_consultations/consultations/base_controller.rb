module GobiertoAdmin
  module GobiertoBudgetConsultations
    module Consultations
      class BaseController < GobiertoAdmin::BaseController
        def ignored_consultation_attributes
          %w(
          created_at updated_at
          budget_amount
          )
        end

        def get_consultation_visibility_levels
          ::GobiertoBudgetConsultations::Consultation.visibility_levels
        end
      end
    end
  end
end
