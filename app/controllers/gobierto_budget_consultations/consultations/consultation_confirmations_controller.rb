module GobiertoBudgetConsultations
  module Consultations
    class ConsultationConfirmationsController < BaseController
      before_action :authenticate_user!
      before_action { verify_user_in!(current_site) }
      before_action :check_consultation_status
      skip_before_action :check_not_responded

      def show
        @consultation_response = find_consultation_response
      end

      private

      def find_consultation_response
        @consultation.consultation_responses.sorted.find_by!(user_id: current_user.id)
      end
    end
  end
end
