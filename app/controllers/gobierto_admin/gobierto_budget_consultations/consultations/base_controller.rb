module GobiertoAdmin
  module GobiertoBudgetConsultations
    module Consultations
      class BaseController < GobiertoAdmin::BaseController
        before_action { gobierto_module_enabled!(current_site, "GobiertoBudgetConsultations") }
        before_action { module_allowed!(current_admin, "GobiertoBudgetConsultations") }

        before_action :set_consultation

        private

        def ignored_consultation_attributes
          %w(
          created_at updated_at
          budget_amount
          )
        end

        def get_consultation_visibility_levels
          ::GobiertoBudgetConsultations::Consultation.visibility_levels
        end

        def set_consultation
          @consultation = find_consultation
        end

        protected

        def find_consultation
          current_site.budget_consultations.find(params[:consultation_id])
        end
      end
    end
  end
end
