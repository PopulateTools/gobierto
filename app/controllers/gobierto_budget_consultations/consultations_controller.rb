module GobiertoBudgetConsultations
  class ConsultationsController < GobiertoBudgetConsultations::ApplicationController
    before_action :set_consultation, only: [:show, :budget_summary]
    before_action :check_consultation_open, only: [:budget_summary]
    before_action :check_not_responded, only: [:show, :budget_summary]

    def index
      consultations = current_site.budget_consultations

      @active_consultations = consultations.active

      # Skip the index view when there's only one active Consultation
      redirect_to @active_consultations.first if @active_consultations.size == 1

      @past_consultations = consultations.past
    end

    def show; end

    def budget_summary; end

    private

    def set_consultation
      @consultation = ConsultationDecorator.new(find_consultation)
    end

    def check_consultation_open
      raise_user_not_authorized unless @consultation.open?
    end

    protected

    def find_consultation
      current_site.budget_consultations.find(params[:id])
    end
  end
end
