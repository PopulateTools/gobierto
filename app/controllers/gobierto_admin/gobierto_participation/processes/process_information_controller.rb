# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    module Processes
      class ProcessInformationController < Processes::BaseController
        def edit
          @process = find_process
          @process_visibility_levels = get_process_visibility_levels
          @process_information_form = ProcessInformationForm.new(@process.attributes.except(*ignored_process_attributes).merge(site_id: current_site.id))
        end

        def update
          @process = find_process
          @process_information_form = ProcessInformationForm.new(process_params.merge(id: params[:id], site_id: current_site.id))

          if @process_information_form.save
            track_update_process
            redirect_to(
              edit_admin_participation_process_process_information_path(@process, process_id: @process),
              notice: t(".success")
            )
          else
            @process_visibility_levels = get_process_visibility_levels
            render :edit
          end
        end

        private

        def find_process
          current_site.processes.find(params[:process_id])
        end

        def current_process
          @process
        end
        helper_method :current_process

        def process_params
          params.require(:process).permit(
            :visibility_level,
            information_text_translations: [*I18n.available_locales]
          )
        end

        def ignored_process_attributes
          %w( created_at updated_at site_id title_translations body_translations slug
              starts ends header_image_url process_type issue_id scope_id)
        end

        def get_process_visibility_levels
          ::GobiertoParticipation::Process.visibility_levels
        end

        def default_activity_params
          { ip: remote_ip, author: current_admin, site_id: current_site.id }
        end

        def track_update_process
          Publishers::GobiertoParticipationProcessActivity.broadcast_event("process_updated", default_activity_params.merge(subject: @process))
        end
      end
    end
  end
end
