# frozen_string_literal: true

module Integration
  module AdminGroupsConcern
    extend ActiveSupport::Concern

    included do
      def regular_admin
        @regular_admin ||= gobierto_admin_admins(:steve)
      end

      def edit_project_group
        @edit_project_group ||= gobierto_admin_admin_groups(:political_agendas_permissions_group)
      end

      def delete_all_projects_group
        @delete_all_projects_group ||= gobierto_admin_admin_groups(:madrid_delete_all_projects_admin_plans_group)
      end

      def delete_assigned_projects_group
        @delete_assigned_projects_group ||= gobierto_admin_admin_groups(:madrid_delete_assigned_projects_admin_plans_group)
      end

      def edit_project_permission
        @edit_project_permission ||= gobierto_admin_group_permissions(:edit_political_agendas)
      end

      def allow_regular_admin_manage_plans
        regular_admin.admin_groups << gobierto_admin_admin_groups(:madrid_manage_plans_group)
      end

      def allow_regular_admin_edit_plans
        regular_admin.admin_groups << gobierto_admin_admin_groups(:madrid_edit_plans_group)
      end

      def allow_regular_admin_edit_project(project)
        edit_project_group.update_attribute(:resource, project)
        edit_project_permission.update_attribute(:resource, project)
        regular_admin.admin_groups << gobierto_admin_admin_groups(:madrid_edit_plans_group)
        regular_admin.admin_groups << edit_project_group
      end

      def allow_regular_admin_delete_all_projects
        regular_admin.admin_groups << delete_all_projects_group
      end

      def allow_regular_admin_delete_assigned_projects
        regular_admin.admin_groups << delete_assigned_projects_group
      end

      def allow_regular_admin_moderate_plans
        regular_admin.admin_groups << gobierto_admin_admin_groups(:madrid_moderate_plans_group)
      end
    end
  end
end
