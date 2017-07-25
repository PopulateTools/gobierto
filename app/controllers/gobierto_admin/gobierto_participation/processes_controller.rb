module GobiertoAdmin
  module GobiertoParticipation
    class ProcessesController < BaseController

      before_action { module_enabled!(current_site,  'GobiertoParticipation') }
      before_action { module_allowed!(current_admin, 'GobiertoParticipation') }

      def index
        @processes = current_site.processes.processes
        @groups    = current_site.processes.groups
      end

      def new
        @process_form = ProcessForm.new(site_id: current_site.id)
        @issues = find_issues
      end

      def edit
        @process = find_process
        @issues  = find_issues

        @process_form = ProcessForm.new(
          @process.attributes.except(*ignored_process_attributes).merge(site_id: current_site.id)
        )
      end

      def create
        @process_form = ProcessForm.new(process_params.merge(site_id: current_site.id))

        if @process_form.save
          redirect_to(
            admin_participation_processes_path,
            notice: t('.success')
          )
        else
          render :new
        end
      end

      def update
        @process = find_process
        @process_form = ProcessForm.new(process_params.merge(id: params[:id], site_id: current_site.id))

        if @process_form.save
          redirect_to(
            edit_admin_participation_process_path(@process),
            notice: t('.success')
          )
        else
          @issues  = find_issues
          render :edit
        end
      end

      private

      def find_process
        current_site.processes.find(params[:id])
      end

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
        %w( visibility_level created_at updated_at site_id title body )
      end

    end
  end
end
