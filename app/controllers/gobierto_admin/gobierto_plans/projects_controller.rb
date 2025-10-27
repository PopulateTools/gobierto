# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class ProjectsController < GobiertoAdmin::GobiertoPlans::BaseController
      COLLECTION_ACTIONS = [:index, :new, :create]

      before_action :find_plan
      before_action :find_project, except: COLLECTION_ACTIONS
      before_action -> { review_allowed_actions! }

      helper_method :admin_projects_actions, :current_controller_allowed_actions, :current_admin_allowed_actions,
                     :current_admin_allowed_update_actions, :current_admin_allowed_unscoped_actions

      def index
        set_filters

        @projects = @relation
      end

      def show
        edit
        render :edit
      end

      def edit
        find_versioned_project
        @unpublish_url = unpublish_admin_plans_plan_project_path(@plan, @project)

        @project_form = NodeForm.new(
          @project.attributes.except(*ignored_project_attributes).merge(
            plan_id: @plan.id,
            options_json: @project.options,
            admin: current_admin,
            version: params[:version],
            allowed_admin_actions: current_admin_allowed_unscoped_actions,
            allowed_controller_actions: current_controller_allowed_actions
          ).merge(versions_defaults)
        )
        initialize_custom_field_form
        set_dashboards_list_path
      end

      def update
        @project_form = NodeForm.new(
          project_params.merge(
            id: params[:id],
            plan_id: params[:plan_id],
            admin: current_admin,
            allowed_admin_actions: current_admin_allowed_unscoped_actions,
            allowed_controller_actions: current_controller_allowed_actions
          )
        )
        save_versions_defaults
        @unpublish_url = unpublish_admin_plans_plan_project_path(@plan, @project)
        @version_index = @project_form.version_index
        initialize_custom_field_form

        if @project_form.save && custom_fields_save
          track_update_activity

          success_message = if suggest_unpublish?
                              t(".suggest_unpublish_html", url: @unpublish_url)
                            elsif reset_moderation?
                              t(".moderation_reset")
                            elsif has_changes?
                              t(".success")
                            else
                              t(".no_changes")
                            end
          redirect_to(
            edit_admin_plans_plan_project_path(@plan, @project),
            notice: success_message
          )
        else
          set_dashboards_list_path
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
          versions_defaults.merge(
            plan_id: @plan.id,
            options_json: {},
            admin: current_admin,
            allowed_admin_actions: current_admin_allowed_unscoped_actions,
            allowed_controller_actions: current_controller_allowed_actions
          )
        )
        initialize_custom_field_form
      end

      def create
        @project_form = NodeForm.new(
          project_params.merge(
            id: params[:id],
            plan_id: params[:plan_id],
            admin: current_admin,
            allowed_admin_actions: current_admin_allowed_unscoped_actions,
            allowed_controller_actions: current_controller_allowed_actions
          )
        )
        initialize_custom_field_form
        save_versions_defaults

        if @project_form.save
          custom_fields_save
          track_create_activity

          redirect_path = if current_controller_allowed_actions.include?(:edit)
                            edit_admin_plans_plan_project_path(@plan, @project_form.node)
                          else
                            admin_plans_plan_projects_path(@plan)
                          end

          redirect_to(
            redirect_path,
            notice: t(".success")
          )
        else
          @project_visibility_levels = project_visibility_levels

          render :new
        end
      end

      def destroy
        project_name = @project.name
        project_assigned_admin_ids = GobiertoAdmin::Admin.joins(:admin_group_memberships)
          .where(admin_groups_admins: { admin_group_id: GobiertoAdmin::AdminGroup.where(resource: @project) })
          .distinct.pluck(:id)
        project_assigned_admin_ids << @project.admin_id if @project.admin_id.present?

        @project.destroy

        track_destroy_activity(project_name:, project_assigned_admin_ids:)

        projects_filter = if filter_params.values.any?(&:present?)
                            { projects_filter: filter_params }
                          else
                            {}
                          end

        redirect_to admin_plans_plan_projects_path(@plan, projects_filter), notice: t(".success")
      end

      def current_controller_allowed_actions
        @current_controller_allowed_actions ||= if @project
                                                  admin_projects_actions[@project.id]&.dig(:controller_actions) || admin_projects_actions&.dig(:default, :controller_actions) || []
                                                else
                                                  admin_projects_actions&.dig(COLLECTION_ACTIONS.include?(action_name.to_sym) ? :collection : :default, :controller_actions) || []
                                                end
      end

      def current_admin_allowed_update_actions
        @current_admin_allowed_update_actions ||= begin
                                                    controller_action = case action_name
                                                                        when "new", "create"
                                                                          :create
                                                                        when "edit", "update"
                                                                          :update
                                                                        end
                                                    if controller_action.present?
                                                      names = permissions_policy.actions_manager.unscoped_names(
                                                        *permissions_policy.scoped_admin_actions(controller_action)
                                                      )
                                                      names & current_admin_allowed_unscoped_actions
                                                    end
                                                  end
      end

      def current_admin_allowed_actions
        @current_admin_allowed_actions ||= if @project
                                             admin_projects_actions[@project.id]&.dig(:admin_actions) || admin_projects_actions&.dig(:default, :admin_actions) || []
                                           else
                                             admin_projects_actions&.dig(COLLECTION_ACTIONS.include?(action_name.to_sym) ? :collection : :default, :admin_actions) || []
                                           end
      end

      def current_admin_allowed_unscoped_actions
        @current_admin_allowed_unscoped_actions ||= permissions_policy.actions_manager.unscoped_names(*current_admin_allowed_actions)
      end

      private

      def permissions_policy
        @permissions_policy ||= GobiertoAdmin::GobiertoPlans::ProjectPolicy.new(
          current_admin: current_admin,
          current_site: current_site,
          project: @project_form&.project || @project,
          plan: @plan
        )
      end

      def review_allowed_actions!
        raise_action_not_allowed unless current_controller_allowed_actions.include?(action_name.to_sym)
      end

      def save_versions_defaults
        [:publish_last_version_automatically, :minor_change].each do |param_key|
          next unless project_params.has_key? param_key

          session["#{param_key}_default"] = @project_form.send(param_key)
        end
      end

      def versions_defaults
        @versions_defaults ||= {
          publish_last_version_automatically: session.fetch(:publish_last_version_automatically_default, @plan.publish_last_version_automatically?),
          minor_change: current_admin_allowed_update_actions.include?(:update_projects_as_minor_change) && session.fetch(:minor_change_default, false)
        }
      end

      def moderation_visibility_action(visibility_level)
        @project = @plan.nodes.find params[:id]
        @project_form = NodeForm.new(
          id: @project.id,
          plan_id: @plan.id,
          admin: current_admin,
          visibility_level: visibility_level,
          disable_attributes_edition: true,
          allowed_admin_actions: current_admin_allowed_unscoped_actions,
          allowed_controller_actions: current_controller_allowed_actions
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
        @form = ProjectsFilterForm.new(filter_params.merge(plan: @plan, admin: current_admin, permissions_policy:))
        editor_filter = /edit/.match?(filter_params["admin_actions"])
        @relation = if [:view_projects_all, :view_projects_assigned].any? { |name| current_admin_allowed_actions.include?(name) } && !editor_filter
                      @form.base_relation
                    else
                      @form.editor_relation
                    end

        @form.filter_params.each do |param|
          @relation = @relation.send(:"with_#{param}", filter_params[param])
        end
      end

      def find_plan
        @plan = current_site.plans.find params[:plan_id]
        @preview_item_url = gobierto_plans_plan_type_preview_url(@plan, host: current_site.domain)
      end

      def find_project
        @project = base_relation.find_by_id params[:id]
      end

      def find_versioned_project
        if @project.published?
          @preview_item_url = gobierto_plans_project_path(slug: @plan.plan_type.slug, year: @plan.year, id: @project.id)
        else
          @preview_item_url = gobierto_plans_project_path(slug: @plan.plan_type.slug, year: @plan.year, id: @project.id, preview_token: current_admin.preview_token)
        end

        return if params[:version].blank?

        version_number = params[:version].to_i
        @version_index = version_number - @project.versions.length
        redirect_to(edit_admin_plans_plan_project_path(@plan, @project), alert: t(".unavailable_version")) and return if version_number < 1 || @version_index >= 0

        @project = @project.versions[@version_index].reify
      end

      def set_dashboards_list_path
        return unless current_site.configuration.gobierto_dashboards_enabled? &&
                      admin_actions_manager.action_allowed?(admin: current_admin, action_name: :manage_dashboards)

        @dashboards_list_path ||= list_admin_plans_plan_dashboards_path(@plan)
      end

      def suggest_unpublish?
        @project_form.allow_publish? && @project_form.project.moderation_locked_edition?(:visibility_level) && @project_form.project.published?
      end

      def reset_moderation?
        @project_form.reset_moderation?
      end

      def has_changes?
        @project_form.has_changes?
      end

      def base_relation
        actions = admin_projects_actions&.dig(COLLECTION_ACTIONS.include?(action_name.to_sym) ? :collection : :default, :admin_actions) || []
        if (actions & permissions_policy.scoped_admin_actions(action_name.to_sym, scope: :all)).present?
          @plan.nodes
        else
          GobiertoAdmin::AdminResourcesQuery.new(current_admin, relation: @plan.nodes).allowed(include_moderated: false)
        end
      end

      def filter_params
        return {} unless params.has_key? :projects_filter

        @filter_params ||= params.require(:projects_filter).permit(ProjectsFilterForm::FILTER_PARAMS)
      end

      def project_params
        params.require(:project).permit(*permitted_update_attributes)
      end

      def admin_update_actions
        @admin_update_actions ||= params.require(:project).permit(:admin_actions)[:admin_actions].to_s.split(",").map(&:to_sym) & current_admin_allowed_update_actions
      end

      def permitted_update_attributes
        {
          moderate_projects: [:moderation_stage],
          publish_projects: [:visibility_level, :moderation_visibility_level],
          edit_projects: [
            :category_id,
            :progress,
            :starts_at,
            :ends_at,
            :options_json,
            :moderation_stage,
            :visibility_level,
            :status_id,
            :position,
            :publish_last_version_automatically,
            name_translations: [*I18n.available_locales]
          ],
          update_projects_as_minor_change: [
            :minor_change
          ],
          create_projects: [
            :category_id,
            :progress,
            :starts_at,
            :ends_at,
            :options_json,
            :moderation_stage,
            :status_id,
            :position,
            :publish_last_version_automatically,
            name_translations: [*I18n.available_locales]
          ]
        }.slice(*admin_update_actions).values.flatten.uniq
      end

      def ignored_project_attributes
        %w(created_at updated_at options admin_id)
      end

      def project_visibility_levels
        ::GobiertoPlans::Node.visibility_levels
      end

      def raise_action_not_allowed
        redirection_path = current_controller_allowed_actions.include?(:index) ? admin_plans_plan_projects_path(@plan) : admin_plans_plans_path
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
          with_version: !@project_form.minor_change
        )
        custom_params_key = self.class.name.demodulize.gsub("Controller", "").underscore.singularize
        return if request.get? || !params.has_key?(custom_params_key) || !@project_form.allow_edit_attributes?

        @custom_fields_form.custom_field_records = params.require(custom_params_key).permit(custom_records: {})
        @project_form.extra_attributes_changed = @custom_fields_form.changed || []
        @new_version = @project_form.attributes_updated?
        unless @project_form.project.new_record? || @project_form.minor_change
          @custom_fields_form.force_new_version = @new_version
        end
      end

      def custom_fields_save
        return true if !@project_form.allow_edit_attributes?

        @custom_fields_form.save
      end

      def track_create_activity
        Publishers::GobiertoPlansProjectActivity.broadcast_event("project_created", default_activity_params.merge(subject: @project_form.node, recipient: @plan))
      end

      def track_update_activity
        return unless @new_version || @project_form.publication_updated?

        Publishers::GobiertoPlansProjectActivity.broadcast_event("project_updated", default_activity_params.merge(subject: @project_form.node, recipient: @plan))
      end

      def track_destroy_activity(options = {})
        Publishers::GobiertoPlansProjectActivity.broadcast_event("project_destroyed", default_activity_params.merge(subject: @plan, recipient: @plan))

        # Broadcast event for admin notifications
        Publishers::AdminTrackable.broadcast_event(
          "project_deleted",
          default_activity_params.merge(
            gid: @plan.to_gid,
            site_id: current_site.id,
            admin_id: current_admin.id,
            project_name: options[:project_name],
            allowed_actions_to_send_notification: [:view_projects, :delete_projects],
            project_assigned_admin_ids: options[:project_assigned_admin_ids]
          )
        )
      end

      def default_activity_params
        { ip: remote_ip, author: current_admin, site_id: current_site.id }
      end
    end
  end
end
