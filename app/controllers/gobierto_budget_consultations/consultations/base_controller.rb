module GobiertoBudgetConsultations
  module Consultations
    class BaseController < GobiertoBudgetConsultations::ApplicationController
      before_action :set_consultation

      private

      def set_consultation
        @consultation = find_consultation
      end

      def check_consultation_status
        raise_consultation_closed unless @consultation.open?
      end

      protected

      def find_consultation
        current_site.budget_consultations.find(params[:consultation_id])
      end

      def raise_consultation_closed
        redirect_to(
          request.referrer || user_root_path,
          alert: "This consultation doesn't allow participations."
        )
      end
    end
  end
end
