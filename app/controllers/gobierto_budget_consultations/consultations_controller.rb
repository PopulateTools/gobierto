module GobiertoBudgetConsultations
  class ConsultationsController < GobiertoBudgetConsultations::ApplicationController
    def index
      consultations = current_site.budget_consultations

      @active_consultations = consultations.active

      # Skip the index view when there's only one active Consultation
      redirect_to @active_consultations.first if @active_consultations.size == 1

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
