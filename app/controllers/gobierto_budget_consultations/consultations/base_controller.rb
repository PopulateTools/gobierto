# frozen_string_literal: true

module GobiertoBudgetConsultations
  module Consultations
    class BaseController < GobiertoBudgetConsultations::ApplicationController
      before_action :set_consultation
      before_action :check_not_responded

      private

      def set_consultation
        @consultation = find_consultation
      end

      def check_consultation_status
        raise_consultation_closed unless @consultation.open?
      end

      protected

      def find_consultation
        current_site.budget_consultations.find(params[:consultation_id])
      end
    end
  end
end
