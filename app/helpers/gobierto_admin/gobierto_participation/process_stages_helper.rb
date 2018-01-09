# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    module ProcessStagesHelper
      def admin_stage_path(stage)
        case stage.stage_type
        when "information"
          if stage.process_stage_page.present?
            edit_admin_participation_process_process_stage_process_stage_page_path(stage.process_stage_page,
                                                                                   process_id: current_process,
                                                                                   process_stage_id: stage.id)
          else
            new_admin_participation_process_process_stage_process_stage_page_path(process_id: current_process,
                                                                                  process_stage_id: stage.id)
          end
        when "agenda"
          admin_participation_process_events_path(stage.process)
        when "polls"
          admin_participation_process_polls_path(stage.process)
        when "contributions"
          admin_participation_process_contribution_containers_path(stage.process)
        when "documents"
          admin_participation_process_file_attachments_path(stage.process)
        when "pages"
          admin_participation_process_pages_path(stage.process)
        when "results"
          if stage.process_stage_page.present?
            edit_admin_participation_process_process_stage_process_stage_page_path(stage.process_stage_page,
                                                                                   process_id: current_process,
                                                                                   process_stage_id: stage.id)
          else
            new_admin_participation_process_process_stage_process_stage_page_path(process_id: current_process,
                                                                                  process_stage_id: stage.id)
          end
        end
      end
    end
  end
end
