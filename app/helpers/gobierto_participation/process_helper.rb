# frozen_string_literal: true

module GobiertoParticipation
  module ProcessHelper
    def phase_url(phase)
      case phase.stage_type
      when "information"
        gobierto_participation_process_information_path(process_id: phase.process.slug)
      when "meetings" # TODO: Meetings????
        gobierto_participation_process_events_path(process_id: phase.process.slug)
      when "polls"
        gobierto_participation_process_polls_path(process_id: phase.process.slug)
      when "ideas"
        gobierto_participation_process_contribution_containers_path(process_id: current_process.slug)
      when "results" # TODO:
        "#"
      end
    end
  end
end
