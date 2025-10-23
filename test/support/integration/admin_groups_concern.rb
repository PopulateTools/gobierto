# frozen_string_literal: true

module Integration
  module AdminGroupsConcern
    extend ActiveSupport::Concern

    included do
      def regular_admin
        @regular_admin ||= gobierto_admin_admins(:steve)
      end

      def allow_regular_admin_edit_plans
        regular_admin.admin_groups << gobierto_admin_admin_groups(:madrid_manage_projects_group)
      end
      alias_method :allow_regular_admin_manage_plans, :allow_regular_admin_edit_plans

      def assigned_admins_project_group
        @assigned_admins_project_group ||= gobierto_admin_admin_groups(:political_agendas_permissions_group)
      end

      def view_all_projects_group
        @view_all_projects_group ||= gobierto_admin_admin_groups(:madrid_view_all_projects_group)
      end

      def view_assigned_projects_group
        @view_assigned_projects_group ||= gobierto_admin_admin_groups(:madrid_view_assigned_projects_group)
      end

      def edit_all_projects_group
        @edit_all_projects_group ||= gobierto_admin_admin_groups(:madrid_edit_all_projects_group)
      end

      def edit_assigned_projects_group
        @edit_assigned_projects_group ||= gobierto_admin_admin_groups(:madrid_edit_assigned_projects_group)
      end

      def publish_all_projects_group
        @publish_all_projects_group ||= gobierto_admin_admin_groups(:madrid_publish_all_projects_group)
      end

      def publish_assigned_projects_group
        @publish_assigned_projects_group ||= gobierto_admin_admin_groups(:madrid_publish_assigned_projects_group)
      end

      def delete_all_projects_group
        @delete_all_projects_group ||= gobierto_admin_admin_groups(:madrid_delete_all_projects_group)
      end

      def delete_assigned_projects_group
        @delete_assigned_projects_group ||= gobierto_admin_admin_groups(:madrid_delete_assigned_projects_group)
      end

      def moderate_all_projects_group
        @moderate_all_projects_group ||= gobierto_admin_admin_groups(:madrid_moderate_all_projects_group)
      end

      def moderate_assigned_projects_group
        @moderate_assigned_projects_group ||= gobierto_admin_admin_groups(:madrid_moderate_assigned_projects_group)
      end

      def manage_projects_group
        @manage_projects_group ||= gobierto_admin_admin_groups(:madrid_manage_projects_group)
      end

      def create_projects_group
        @create_projects_group ||= gobierto_admin_admin_groups(:madrid_create_projects_group)
      end

      def manage_plans_dashboards_group
        @manage_plans_dashboards_group ||= gobierto_admin_admin_groups(:madrid_manage_plans_dashboards_group)
      end

      def view_plans_dashboards_group
        @view_plans_dashboards_group ||= gobierto_admin_admin_groups(:madrid_view_plans_dashboards_group)
      end

      def view_project_permission
        @view_project_permission ||= gobierto_admin_group_permissions(:view_political_agendas)
      end

      def edit_project_permission
        @edit_project_permission ||= gobierto_admin_group_permissions(:edit_political_agendas)
      end

      def publish_project_permission
        @publish_project_permission ||= gobierto_admin_group_permissions(:publish_political_agendas)
      end

      def assign_project_to_regular_admin(project)
        site = project.plan.site
        group = GobiertoAdmin::AdminGroup.find_or_initialize_by(resource: project, group_type: GobiertoAdmin::AdminGroup.group_types[:system], site:)

        if group.new_record?
          group.name = "resource_group_GobiertoPlans::Node_#{project.id}"
          group.save
        end
        regular_admin.admin_groups << group
      end

      def allow_regular_admin_view_all_projects
        regular_admin.admin_groups << view_all_projects_group
      end

      def allow_regular_admin_view_assigned_projects
        regular_admin.admin_groups << view_assigned_projects_group
      end

      def allow_regular_admin_view_project(project)
        allow_regular_admin_view_assigned_projects
        assign_project_to_regular_admin(project)
      end

      def allow_regular_admin_edit_all_projects
        regular_admin.admin_groups << edit_all_projects_group
      end

      def allow_regular_admin_edit_assigned_projects
        regular_admin.admin_groups << edit_assigned_projects_group
      end

      def allow_regular_admin_edit_project(project)
        allow_regular_admin_edit_assigned_projects
        assign_project_to_regular_admin(project)
      end

      def allow_regular_admin_publish_all_projects
        regular_admin.admin_groups << publish_all_projects_group
      end

      def allow_regular_admin_publish_assigned_projects
        regular_admin.admin_groups << publish_assigned_projects_group
      end

      def allow_regular_admin_publish_project(project)
        allow_regular_admin_publish_assigned_projects
        assign_project_to_regular_admin(project)
      end

      def allow_regular_admin_delete_all_projects
        regular_admin.admin_groups << delete_all_projects_group
      end

      def allow_regular_admin_delete_assigned_projects
        regular_admin.admin_groups << delete_assigned_projects_group
      end

      def allow_regular_admin_delete_project(project)
        allow_regular_admin_delete_assigned_projects
        assign_project_to_regular_admin(project)
      end

      def allow_regular_admin_moderate_all_projects
        regular_admin.admin_groups << moderate_all_projects_group
      end

      def allow_regular_admin_moderate_assigned_projects
        regular_admin.admin_groups << moderate_assigned_projects_group
      end

      def allow_regular_admin_moderate_project(project)
        allow_regular_admin_moderate_assigned_projects
        assign_project_to_regular_admin(project)
      end

      def allow_regular_admin_manage_projects
        regular_admin.admin_groups << manage_projects_group
      end

      def allow_regular_admin_create_projects
        regular_admin.admin_groups << create_projects_group
      end

      def allow_regular_admin_manage_dashboards
        regular_admin.admin_groups << manage_plans_dashboards_group
      end

      def allow_regular_admin_view_dashboards
        regular_admin.admin_groups << view_plans_dashboards_group
      end
    end
  end
end
