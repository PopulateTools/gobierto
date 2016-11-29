module GobiertoBudgetConsultations
  class ConsultationsController < GobiertoBudgetConsultations::ApplicationController
    def index
      @consultations = current_site.budget_consultations.active
    end

    def show
      @consultation = find_consultation
    end

    private

    def find_consultation
      current_site.budget_consultations.active.find(params[:id])
    end
  end
end
