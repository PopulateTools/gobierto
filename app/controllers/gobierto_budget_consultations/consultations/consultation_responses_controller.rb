module GobiertoBudgetConsultations
  module Consultations
    class ConsultationResponsesController < GobiertoBudgetConsultations::ApplicationController
      before_action :authenticate_user!
      before_action { verify_user_in!(current_site) }

      def new
      end

      def create
      end
    end
  end
end
