# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    module Processes
      class ProcessStagesSortController < Processes::BaseController
        def create
          current_process.stages.update_positions(process_stages_sort_params)
          head :no_content
        end

        private

        def process_stages_sort_params
          params.require(:positions).permit!
        end
      end
    end
  end
end
