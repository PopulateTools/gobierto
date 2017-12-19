# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    module ProcessStagesHelper
      def admin_phase_url(phase)
        case phase.stage_type
        when "information"
          edit_admin_participation_process_process_information_path(id: current_process,
                                                                    process_id: current_process)
        when "meetings" # TODO: Meetings????
          "#"
        when "polls"
          admin_participation_process_polls_path(phase.process)
        when "ideas"
          admin_participation_process_contribution_containers_path(phase.process)
        when "results" # TODO:
          "#"
        end
      end
    end
  end
end
