module GobiertoBudgetConsultations
  module Consultations
    class ConsultationResponsesController < BaseController
      before_action :authenticate_user!
      before_action :check_consultation_status
      before_action { verify_user_in!(current_site) }

      def new
      end

      def create
      end
    end
  end
end
