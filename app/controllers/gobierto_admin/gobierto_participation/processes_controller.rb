module GobiertoAdmin
  module GobiertoParticipation
    class ProcessesController < BaseController

      before_action { module_enabled!(current_site,  'GobiertoParticipation') }
      before_action { module_allowed!(current_admin, 'GobiertoParticipation') }

      def index
        @processes = current_site.processes.process
        @groups    = current_site.processes.group_process
      end

      def new
        @process_form = ProcessForm.new(site_id: current_site.id)
        @process_visibility_levels = get_process_visibility_levels
        @issues = find_issues
      end

      def edit
        @process = find_process
        @issues  = find_issues
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
            notice: t('.success')
          )
        else
          @issues = find_issues
          @process_visibility_levels = get_process_visibility_levels
          render :new
        end
      end

      def update
        @process = find_process
        @process_form = ProcessForm.new(process_params.merge(id: params[:id], site_id: current_site.id))

        if @process_form.save
          track_update_process
          redirect_to(
            edit_admin_participation_process_path(@process),
            notice: t('.success')
          )
        else
          @issues = find_issues
          @process_visibility_levels = get_process_visibility_levels
          render :edit
        end
      end

      private

      def find_process
        current_site.processes.find(params[:id])
      end

      def current_process
        @process
      end
      helper_method :current_process

      def find_issues
        current_site.issues.collect { |issue| [ issue.name, issue.id ] }
      end

      def process_params
        params.require(:process).permit(
          :slug,
          :process_type,
          :starts,
          :ends,
          :header_image,
          :issue_id,
          :visibility_level,
          title_translations: [*I18n.available_locales],
          body_translations:  [*I18n.available_locales],
          information_text_translations: [*I18n.available_locales],
          stages_attributes: [
            :stage_type,
            :slug,
            :starts,
            :ends,
            :active,
            title_translations: [*I18n.available_locales],
            description_translations: [*I18n.available_locales]
          ]
        )
      end

      def ignored_process_attributes
        %w( created_at updated_at site_id title body information_text_translations)
      end

      def default_activity_params
        { ip: remote_ip, author: current_admin, site_id: current_site.id }
      end

      def track_create_process
        Publishers::GobiertoParticipationProcessActivity.broadcast_event('process_created', default_activity_params.merge(subject: @process_form.process))
      end

      def track_update_process
        Publishers::GobiertoParticipationProcessActivity.broadcast_event('process_updated', default_activity_params.merge(subject: @process))
      end

      def get_process_visibility_levels
        ::GobiertoParticipation::Process.visibility_levels
      end

    end
  end
end
