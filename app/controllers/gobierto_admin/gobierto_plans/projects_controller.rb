# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class ProjectsController < GobiertoAdmin::GobiertoPlans::BaseController
      before_action :find_plan
      before_action -> { module_allowed_action!(current_admin, current_admin_module, :edit) }, only: [:new, :create, :destroy]
      before_action -> { module_allowed_action!(current_admin, current_admin_module, [:edit, :moderate]) }, only: [:index, :edit, :update]

      helper_method :current_admin_actions

      def index
        set_filters

        @projects = @relation
      end

      def edit
        find_versioned_project
        @unpublish_url = unpublish_admin_plans_plan_project_path(@plan, @project)

        @project_form = NodeForm.new(
          @project.attributes.except(*ignored_project_attributes).merge(
            plan_id: @plan.id,
            options_json: @project.options,
            admin: current_admin,
            version: params[:version]
          )
        )
        initialize_custom_field_form
      end

      def update
        @project = @plan.nodes.find params[:id]
        @project_form = NodeForm.new(project_params.merge(id: params[:id], plan_id: params[:plan_id], admin: current_admin))
        @unpublish_url = unpublish_admin_plans_plan_project_path(@plan, @project)
        @version_index = @project_form.version_index
        initialize_custom_field_form

        if @project_form.save && custom_fields_save
          success_message = if suggest_unpublish?
                              t(".suggest_unpublish_html", url: @unpublish_url)
                            else
                              t(".success")
                            end
          redirect_to(
            edit_admin_plans_plan_project_path(@plan, @project),
            notice: success_message
          )
        else
          render :edit
        end
      end

      def unpublish
        moderation_visibility_action(:draft)
      end

      def publish
        moderation_visibility_action(:published)
      end

      def new
        @project_visibility_levels = project_visibility_levels

        @project_form = NodeForm.new(
          plan_id: @plan.id,
          options_json: {},
          admin: current_admin
        )
        initialize_custom_field_form
      end

      def create
        @project_form = NodeForm.new(project_params.merge(id: params[:id], plan_id: params[:plan_id], admin: current_admin))
        initialize_custom_field_form

        if @project_form.save
          custom_fields_save
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
        raise_action_not_allowed unless current_admin_actions.include? :destroy

        @project = @plan.nodes.find params[:id]

        @project.destroy

        projects_filter = if filter_params.values.any?(&:present?)
                            { projects_filter: filter_params }
                          else
                            {}
                          end

        redirect_to admin_plans_plan_projects_path(@plan, projects_filter), notice: t(".success")
      end

      def current_admin_actions
        @current_admin_actions ||= GobiertoAdmin::GobiertoPlans::ProjectPolicy.new(
          current_admin: current_admin,
          current_site: current_site,
          project: @project_form&.project || @project
        ).allowed_actions
      end

      private

      def moderation_visibility_action(visibility_level)
        @project = @plan.nodes.find params[:id]
        @project_form = NodeForm.new(
          id: @project.id,
          plan_id: @plan.id,
          admin: current_admin,
          visibility_level: visibility_level,
          disable_attributes_edition: true
        )

        if @project_form.save
          redirect_to(
            edit_admin_plans_plan_project_path(@plan, @project),
            notice: t(".success")
          )
        else
          redirect_to(
            edit_admin_plans_plan_project_path(@plan, @project),
            alert: t(".error")
          )
        end
      end

      def set_filters
        @relation = base_relation
        @form = ProjectsFilterForm.new(filter_params.merge(plan: @plan, admin: current_admin))
        @form.filter_params.each do |param|
          @relation = @relation.send(:"with_#{param}", filter_params[param])
        end
      end

      def find_plan
        @plan = current_site.plans.find params[:plan_id]
        @preview_item_url = gobierto_plans_plan_type_preview_url(@plan, host: current_site.domain)
      end

      def find_versioned_project
        @project = @plan.nodes.find params[:id]

        return if params[:version].blank?

        version_number = params[:version].to_i
        @version_index = version_number - @project.versions.length
        redirect_to(edit_admin_plans_plan_project_path(@plan, @project), alert: t(".unavailable_version")) and return if version_number < 1 || @version_index >= 0

        @project = @project.versions[@version_index].reify
      end

      def suggest_unpublish?
        @project_form.allow_moderate? && @project_form.project.moderation_locked_edition?(:visibility_level) && @project_form.project.published?
      end

      def base_relation
        @plan.nodes
      end

      def filter_params
        return {} unless params.has_key? :projects_filter

        @filter_params ||= params.require(:projects_filter).permit(ProjectsFilterForm::FILTER_PARAMS)
      end

      def project_params
        if current_admin_actions.include? :update_attributes
          params.require(:project).permit(
            :category_id,
            :progress,
            :starts_at,
            :ends_at,
            :options_json,
            :visibility_level,
            :moderation_visibility_level,
            :moderation_stage,
            :status_id,
            :position,
            name_translations: [*I18n.available_locales]
          )
        else
          params.require(:project).permit(
            :visibility_level,
            :moderation_visibility_level,
            :moderation_stage
          )
        end
      end

      def ignored_project_attributes
        %w(created_at updated_at options admin_id)
      end

      def project_visibility_levels
        ::GobiertoPlans::Node.visibility_levels
      end

      def raise_action_not_allowed
        redirection_path = current_admin_actions.include?(:index) ? admin_plans_plan_projects_path(@plan) : edit_admin_plans_plan_path(@plan)
        redirect_to(
          redirection_path,
          alert: t("gobierto_admin.module_helper.not_enabled")
        )
      end

      def initialize_custom_field_form
        @custom_fields_form = ::GobiertoAdmin::GobiertoCommon::CustomFieldRecordsForm.new(
          site_id: current_site.id,
          item: @project_form.project,
          instance: @plan,
          version_index: @version_index,
          with_version: true
        )
        custom_params_key = self.class.name.demodulize.gsub("Controller", "").underscore.singularize
        return if request.get? || !params.has_key?(custom_params_key)

        @custom_fields_form.custom_field_records = params.require(custom_params_key).permit(custom_records: {})
        @new_version = @custom_fields_form.changed? || @project_form.attributes_updated?
        unless @project_form.project.new_record?
          @custom_fields_form.force_new_version = @new_version
          @project_form.force_new_version = @new_version
        end
      end

      def custom_fields_save
        @custom_fields_form.save
      end
    end
  end
end
