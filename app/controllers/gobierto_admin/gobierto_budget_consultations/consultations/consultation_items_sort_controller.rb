# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoBudgetConsultations
    module Consultations
      class ConsultationItemsSortController < Consultations::BaseController
        def create
          @consultation.consultation_items.update_positions(consultation_items_sort_params)
          head :no_content
        end

        private

        def consultation_items_sort_params
          params.require(:positions).permit!
        end
      end
    end
  end
end
