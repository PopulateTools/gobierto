# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    module ProcessStagesHelper
      def admin_stage_url(stage)
        case stage.stage_type
        when "information"
          edit_admin_participation_process_process_information_path(id: current_process,
                                                                    process_id: current_process)
        when "agenda" # TODO: Meetings????
          "#"
        when "polls"
          admin_participation_process_polls_path(stage.process)
        when "ideas"
          admin_participation_process_contribution_containers_path(stage.process)
        when "results" # TODO:
          "#"
        end
      end
    end
  end
end
