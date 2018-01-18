# frozen_string_literal: true

module GobiertoParticipation
  module ProcessHelper
    def stage_url(stage)
      case stage.stage_type
      when "information"
        if stage.process_stage_page.present?
          gobierto_participation_process_page_path(id: stage.process_stage_page.page.slug,
                                                   process_id: stage.process.slug,
                                                   page: "stage")
        end
      when "agenda"
        gobierto_participation_process_events_path(process_id: stage.process.slug)
      when "polls"
        gobierto_participation_process_polls_path(process_id: stage.process.slug)
      when "contributions"
        gobierto_participation_process_contribution_containers_path(process_id: current_process.slug)
      when "documents"
        gobierto_participation_process_attachments_path(process_id: stage.process.slug)
      when "pages"
        gobierto_participation_process_pages_path(process_id: stage.process.slug)
      when "results"
        if stage.process_stage_page.present?
          gobierto_participation_process_page_path(id: stage.process_stage_page.page.slug,
                                                   process_id: stage.process.slug,
                                                   page: "stage")
        end
      end
    end
  end
end
