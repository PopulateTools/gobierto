# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    class ProcessesController < GobiertoAdmin::BaseController
      before_action { module_enabled!(current_site, "GobiertoParticipation") }
      before_action { module_allowed!(current_admin, "GobiertoParticipation") }

      helper_method :gobierto_participation_process_preview_url

      def new
        @process_form = ProcessForm.new(site_id: current_site.id)
        @process_visibility_levels = get_process_visibility_levels
        @issues = find_issues
        @scopes = find_scopes
      end

      def edit
        load_process(preview: true)
        @issues = find_issues
        @scopes = find_scopes
        @process_visibility_levels = get_process_visibility_levels

        @process_form = ProcessForm.new(
          @process.attributes.except(*ignored_process_attributes).merge(site_id: current_site.id)
        )
      end

      def create
        @process_form = ProcessForm.new(process_params.merge(site_id: current_site.id))

        if @process_form.save
          track_create_process
          redirect_to(
            edit_admin_participation_process_path(@process_form.process),
            notice: [
              t(".success_#{@process_form.process.process_type}_html", link: gobierto_participation_process_preview_url(@process_form.process, host: current_site.domain)),
              t(".add_stages")
            ]
          )
        else
          @issues = find_issues
          @scopes = find_scopes
          @process_visibility_levels = get_process_visibility_levels
          render :new
        end
      end

      def update
        load_process(preview: true)
        @process_form = ProcessForm.new(process_params.merge(id: params[:id], site_id: current_site.id))

        if @process_form.save
          track_update_process
          redirect_to(
            edit_admin_participation_process_path(@process),
            notice: t(".success_#{@process.process_type}_html", link: gobierto_participation_process_preview_url(@process_form.process, host: current_site.domain))
          )
        else
          @issues = find_issues
          @scopes = find_scopes
          @process_visibility_levels = get_process_visibility_levels
          render :edit
        end
      end

      def destroy
        load_process
        @process.destroy

        redirect_to admin_participation_path, notice: t(".success_#{@process.process_type}")
      end

      def recover
        @process = find_archived_process
        @process.restore

        redirect_to admin_participation_path, notice: t(".success_#{@process.process_type}")
      end

      def update_current_stage
        stages = ::GobiertoParticipation::Process.find(params[:process_id]).stages
        stages.update_all(active: false)
        active_stage = ::GobiertoParticipation::ProcessStage.find(params[:active_stage_id])
        active_stage.update(active: true)

        respond_to do |format|
          format.js { render layout: false }
        end
      end

      private

      def load_process(opts = {})
        @process = current_site.processes.find(params[:id])
        @preview_item = current_process if opts[:preview]
      end

      def find_archived_process
        current_site.processes.with_archived.find(params[:process_id])
      end

      def current_process
        @process
      end
      helper_method :current_process

      def find_issues
        current_site.issues.collect { |issue| [issue.name, issue.id] }
      end

      def find_scopes
        current_site.scopes.collect { |scope| [scope.name, scope.id] }
      end

      def process_params
        params.require(:process).permit(
          :slug,
          :process_type,
          :starts,
          :ends,
          :header_image,
          :issue_id,
          :scope_id,
          :visibility_level,
          :has_duration,
          title_translations: [*I18n.available_locales],
          body_translations:  [*I18n.available_locales],
          body_source_translations: [*I18n.available_locales]
        )
      end

      def ignored_process_attributes
        %w(created_at updated_at site_id title body archived_at)
      end

      def default_activity_params
        { ip: remote_ip, author: current_admin, site_id: current_site.id }
      end

      def track_create_process
        Publishers::GobiertoParticipationProcessActivity.broadcast_event("process_created", default_activity_params.merge(subject: @process_form.process))
      end

      def track_update_process
        Publishers::GobiertoParticipationProcessActivity.broadcast_event("process_updated", default_activity_params.merge(subject: @process))
      end

      def get_process_visibility_levels
        ::GobiertoParticipation::Process.visibility_levels
      end

      def gobierto_participation_process_preview_url(process, options = {})
        if process.draft?
          options.merge!(preview_token: current_admin.preview_token)
        end
        gobierto_participation_process_url(process.slug, options)
      end
    end
  end
end
