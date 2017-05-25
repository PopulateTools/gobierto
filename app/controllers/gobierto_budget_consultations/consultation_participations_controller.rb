# frozen_string_literal: true

module GobiertoBudgetConsultations
  class ConsultationParticipationsController < GobiertoBudgetConsultations::ApplicationController
    def show
      @consultation_response = find_consultation_response
      @consultation = @consultation_response.consultation
    end

    private

    def find_consultation_response
      current_site.budget_consultation_responses.active.find_by!(sharing_token: params[:id])
    end
  end
end
