module GobiertoBudgetConsultations
  module Consultations
    class ConsultationConfirmationsController < BaseController
      before_action :authenticate_user!
      before_action { verify_user_in!(current_site) }
      before_action :check_consultation_status

      def new
        @consultation_response = find_consultation_response
      end

      def show
        @consultation_response = find_consultation_response
      end

      def create
        @consultation_response = find_consultation_response

        if @consultation_response.active!
          redirect_to [@consultation, :show_confirmation]
        else
          @consultation_response = find_consultation_response
          render :new
        end
      end

      private

      def find_consultation_response
        @consultation.consultation_responses.sorted.find_by!(user_id: current_user.id)
      end
    end
  end
end
