module GobiertoAdmin
  module GobiertoBudgetConsultations
    module Consultations
      class ConsultationResponsesController < Consultations::BaseController
        def index
          @consultation_responses = @consultation.consultation_responses.sorted
        end

        def show
          @consultation_response = find_consultation_response
        end

        private

        def find_consultation_response
          @consultation.consultation_responses.find(params[:id])
        end
      end
    end
  end
end
