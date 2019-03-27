# frozen_string_literal: true

module GobiertoBudgetConsultations
  module Consultations
    class ConsultationItemsController < BaseController
      before_action :check_consultation_status

      def index
        @consultation_items = @consultation.consultation_items.sorted

        respond_to do |format|
          format.html
          format.json
        end
      end
    end
  end
end
