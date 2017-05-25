# frozen_string_literal: true

module GobiertoBudgetConsultations
  class ConsultationsController < GobiertoBudgetConsultations::ApplicationController
    before_action :set_consultation, only: [:show]
    before_action :check_not_responded, only: [:show]

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

    protected

    def find_consultation
      current_site.budget_consultations.find(params[:id])
    end
  end
end
