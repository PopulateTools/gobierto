# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    module Processes
      class ProcessContributionContainersController < Processes::BaseController

        helper_method :gobierto_participation_contribution_container_preview_url

        def index
          @contribution_containers = find_process.contribution_containers
          @archived_contribution_containers = find_process.contribution_containers.only_archived
        end

        def show
          @contribution_container = find_contribution_container
          @process = @contribution_container.process
          @votes_headers = ::GobiertoParticipation::ContributionDecorator.headings
        end

        def new
          @process = find_process
          @contribution_container_visibility_levels = contribution_container_visibility_levels
          @contribution_container_form = ContributionContainerForm.new(site_id: current_site.id,
                                                                       process_id: @process.id,
                                                                       admin_id: current_admin.id)
        end

        def edit
          @contribution_container = find_contribution_container
          @contribution_container_visibility_levels = contribution_container_visibility_levels
          @contribution_container_form = ContributionContainerForm.new(
            @contribution_container.attributes.except(*ignored_contribution_container_attributes)
          )
        end

        def create
          @process = find_process
          @contribution_container_visibility_levels = contribution_container_visibility_levels
          @contribution_container_form = ContributionContainerForm.new(contribution_container_params.merge(site_id: current_site.id,
                                                                                                           process_id: @process.id,
                                                                                                           admin_id: current_admin.id))

          if @contribution_container_form.save
            track_create_activity

            redirect_to(
              edit_admin_participation_process_contribution_container_path(
                process_id: @process.id,
                id: @contribution_container_form.contribution_container.id), notice: t(".success_html",
                                                                             link: gobierto_participation_contribution_container_preview_url(@contribution_container_form.contribution_container, host: current_site.domain))
            )
          else
            render :edit
          end
        end

        def update
          @contribution_container = find_contribution_container
          @contribution_container_visibility_levels = contribution_container_visibility_levels
          @process = @contribution_container.process
          @contribution_container_form = ContributionContainerForm.new(contribution_container_params.merge(id: @contribution_container.id,
                                                                                                           process_id: @process.id,
                                                                                                           admin_id: current_admin.id))
          if @contribution_container_form.save
            track_update_activity

            redirect_to(
              edit_admin_participation_process_contribution_container_path(
                id: @contribution_container_form.contribution_container.id,
                process_id: @process.id), notice: t(".success_html",
                                          link: gobierto_participation_contribution_container_preview_url(@contribution_container_form.contribution_container, host: current_site.domain))
            )
          else
            @contribution_container_visibility_levels = contribution_container_visibility_levels
            render :edit
          end
        end

        def destroy
          @contribution_container = find_contribution_container
          @contribution_container.destroy
          process = find_process if params[:process_id]

          redirect_to admin_participation_process_contribution_containers_path(process_id: process), notice: t(".success")
        end

        def recover
          @contribution_container = find_archived_contribution_container
          @contribution_container.restore

          process = find_process if params[:process_id]

          redirect_to admin_participation_process_contribution_containers_path(process_id: process), notice: t(".success")
        end

        private

        def track_create_activity
          Publishers::GobiertoParticipationContributionContainerActivity.broadcast_event("contribution_container_created", default_activity_params.merge(subject: @contribution_container_form.contribution_container))
        end

        def track_update_activity
          Publishers::GobiertoParticipationContributionContainerActivity.broadcast_event("contribution_container_updated", default_activity_params.merge(subject: @contribution_container))
        end

        def default_activity_params
          { ip: remote_ip, author: current_admin, site_id: current_site.id }
        end

        def contribution_container_visibility_levels
          ::GobiertoParticipation::ContributionContainer.visibility_levels
        end

        def contribution_container_params
          params.require(:contribution_container).permit(
            :visibility_level,
            :visibility_user_level,
            :contribution_type,
            :starts,
            :ends,
            title_translations: [*I18n.available_locales],
            description_translations:  [*I18n.available_locales]
          )
        end

        def ignored_contribution_container_attributes
          %w(slug created_at updated_at archived_at)
        end

        def find_contribution_container
          current_site.contribution_containers.find(params[:id])
        end

        def find_archived_contribution_container
          current_site.contribution_containers.with_archived.find(params[:contribution_container_id])
        end

        def find_process
          current_site.processes.find(params[:process_id])
        end

        def gobierto_participation_contribution_container_preview_url(contribution_container, options = {})
          if contribution_container.draft?
            options.merge!(preview_token: current_admin.preview_token)
          end
          gobierto_participation_process_contribution_container_url(contribution_container.process.slug,
                                                                    contribution_container.slug,
                                                                    options)

        end
      end
    end
  end
end
