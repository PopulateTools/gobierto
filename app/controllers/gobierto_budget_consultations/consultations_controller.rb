module GobiertoBudgetConsultations
  class ConsultationsController < GobiertoBudgetConsultations::ApplicationController
    before_action :set_consultation, :check_consultation_status, only: :show

    def index
      consultations = current_site.budget_consultations

      @active_consultations = consultations.active

      # Skip the index view when there's only one active Consultation
      redirect_to @active_consultations.first if @active_consultations.size == 1

      @past_consultations = consultations.past
    end

    def show; end

    private

    def set_consultation
      @consultation = ConsultationDecorator.new(find_consultation)
    end

    def check_consultation_status
      raise_user_not_authorized if @consultation.draft?
    end

    protected

    def find_consultation
      current_site.budget_consultations.find(params[:id])
    end
  end
end
