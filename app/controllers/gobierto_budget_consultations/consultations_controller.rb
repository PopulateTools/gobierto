# frozen_string_literal: true

module GobiertoBudgetConsultations
  class ConsultationsController < GobiertoBudgetConsultations::ApplicationController

    include PreviewTokenHelper

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

    def budget_consultations_scope
      valid_preview_token? ? current_site.budget_consultations.draft : current_site.budget_consultations.not_draft
    end

    protected

    def find_consultation
      budget_consultations_scope.find(params[:id])
    end
  end
end
