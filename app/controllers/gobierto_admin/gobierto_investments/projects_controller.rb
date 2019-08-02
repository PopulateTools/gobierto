# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoInvestments
    class ProjectsController < GobiertoAdmin::GobiertoInvestments::BaseController

      def index
        @projects = current_site.projects.order(id: :desc)
      end

      def new
        @project_form = ProjectForm.new(site_id: current_site.id, admin_id: current_admin.id, ip: remote_ip)
        initialize_custom_field_form
      end

      def edit
        @project = find_project

        @project_form = ProjectForm.new(
          @project.attributes.except(*ignored_project_attributes).merge(site_id: current_site.id, admin_id: current_admin.id, ip: remote_ip)
        )
        initialize_custom_field_form
      end

      def create
        @project_form = ProjectForm.new(project_params.merge(site_id: current_site.id, admin_id: current_admin.id, ip: remote_ip))
        initialize_custom_field_form

        if @project_form.save
          custom_fields_save
          redirect_to(
            edit_admin_investments_project_path(@project_form.project),
            notice: t(".success")
          )
        else
          render :new
        end
      end

      def update
        @project = find_project

        @project_form = ProjectForm.new(
          project_params.merge(id: params[:id], site_id: current_site.id, admin_id: current_admin.id, ip: remote_ip)
        )
        initialize_custom_field_form

        if @project_form.save && custom_fields_save
          redirect_to(
            edit_admin_investments_project_path(@project),
            notice: t(".success")
          )
        else
          render :edit
        end
      end

      def destroy
        @project = find_project

        @project.destroy

        redirect_to admin_investments_projects_path, notice: t(".success")
      end

      private

      def project_params
        params.require(:project).permit(
          :external_id,
          title_translations: [*I18n.available_locales]
        )
      end

      def ignored_project_attributes
        %w(created_at updated_at site_id)
      end

      def find_project
        current_site.projects.find(params[:id])
      end

      def initialize_custom_field_form
        @custom_fields_form = ::GobiertoAdmin::GobiertoCommon::CustomFieldRecordsForm.new(
          site_id: current_site.id,
          item: @project_form.project
        )
        custom_params_key = self.class.name.demodulize.gsub("Controller", "").underscore.singularize
        return if request.get? || !params.has_key?(custom_params_key)

        @custom_fields_form.custom_field_records = params.require(custom_params_key).permit(custom_records: {})
      end

      def custom_fields_save
        @custom_fields_form.save
      end

    end
  end
end
