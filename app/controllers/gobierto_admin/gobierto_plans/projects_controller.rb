# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class ProjectsController < BaseController
      before_action :find_plan

      def index
        find_plan
        set_filters

        @projects = @relation
      end

      def edit
        find_plan
        find_versioned_project
        @project_visibility_levels = project_visibility_levels

        @project_form = NodeForm.new(
          @project.attributes.except(*ignored_project_attributes).merge(
            plan_id: @plan.id,
            options_json: @project.options
          )
        )
      end

      def update
        find_plan
        @project = @plan.nodes.find params[:id]
        @project_form = NodeForm.new(project_params.merge(id: params[:id], plan_id: params[:plan_id]))

        if @project_form.save
          redirect_to(
            edit_admin_plans_plan_project_path(@plan, @project),
            notice: t(".success")
          )
        else
          render :edit
        end
      end

      def new
        find_plan
        @project_visibility_levels = project_visibility_levels

        @project_form = NodeForm.new(
          plan_id: @plan.id,
          options_json: {}
        )
      end

      def create
        find_plan

        @project_form = NodeForm.new(project_params.merge(id: params[:id], plan_id: params[:plan_id]))

        if @project_form.save
          redirect_to(
            edit_admin_plans_plan_project_path(@plan, @project_form.node),
            notice: t(".success")
          )
        else
          @project_visibility_levels = project_visibility_levels

          render :new
        end
      end

      def destroy
        find_plan
        set_filters

        @project = @plan.nodes.find params[:id]
        @project.destroy

        projects_filter = if filter_params.values.any?(&:present?)
                            { projects_filter: filter_params }
                          else
                            {}
                          end

        redirect_to admin_plans_plan_projects_path(@plan, projects_filter), notice: t(".success")
      end

      private

      def set_filters
        @relation = base_relation
        @form = ProjectsFilterForm.new(filter_params.merge(plan: @plan))
        @form.filter_params.each do |param|
          @relation = @relation.send(:"with_#{param}", filter_params[param])
        end
      end

      def find_plan
        @plan = current_site.plans.find params[:plan_id]
      end

      def find_versioned_project
        @project = @plan.nodes.find params[:id]

        return if params[:version].blank?

        version_number = params[:version].to_i
        index = version_number - @project.versions.length
        redirect_to(edit_admin_plans_plan_project_path(@plan, @project), alert: t(".unavailable_version")) and return if version_number < 1 || index >= 0

        @project = @project.versions[index].reify
      end

      def base_relation
        @plan.nodes
      end

      def filter_params
        return {} unless params.has_key? :projects_filter

        @filter_params ||= params.require(:projects_filter).permit(ProjectsFilterForm::FILTER_PARAMS)
      end

      def project_params
        params.require(:project).permit(
          :category_id,
          :progress,
          :starts_at,
          :ends_at,
          :options_json,
          name_translations: [*I18n.available_locales],
          status_translations: [*I18n.available_locales]
        )
      end

      def ignored_project_attributes
        %w(created_at updated_at options)
      end

      def project_visibility_levels
        ::GobiertoPlans::Node.visibility_levels
      end
    end
  end
end
