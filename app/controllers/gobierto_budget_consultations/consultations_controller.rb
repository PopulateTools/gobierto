module GobiertoBudgetConsultations
  class ConsultationsController < GobiertoBudgetConsultations::ApplicationController
    def index
      consultations = current_site.budget_consultations

      @active_consultations = consultations.active
      @past_consultations = consultations.past
    end

    def show
      @consultation = ConsultationDecorator.new(find_consultation)
    end

    private

    def find_consultation
      current_site.budget_consultations.find(params[:id])
    end
  end
end
