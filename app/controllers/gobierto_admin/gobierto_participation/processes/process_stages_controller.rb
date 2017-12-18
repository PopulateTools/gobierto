# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    module Processes
      class ProcessStagesController < Processes::BaseController
        def destroy
          @process_stage = find_process_stage

          if @process_stage.destroy
            redirect_to edit_admin_participation_process_path(@process_stage.process), notice: t(".success")
          else
            redirect_to edit_admin_participation_process_path(@process_stage.process), alert: t(".default")
          end
        end

        private

        def find_process_stage
          ::GobiertoParticipation::ProcessStage.find(params[:id])
        end
      end
    end
  end
end
