# frozen_string_literal: true

module GobiertoPlans
  class AdminActionsManager < GobiertoAdmin::AdminActionsManager
    ACTIONS_LIST = {
      create_projects: {},
      view_projects: { scopes: [:all, :assigned] },
      edit_projects: { scopes: [:all, :assigned] },
      moderate_projects: { scopes: [:all, :assigned ] },
      publish_projects: {},
      delete_projects: { scopes: [:all, :assigned ] },
      manage: {},
      manage_dashboards: { module: "gobierto_dashboards" },
      view_dashboards: { module: "gobierto_dashboards" },
    }.freeze

    def action_names
      ACTIONS_LIST.map do |action_name, options|
        next unless options[:module].blank? || modules.include?(options[:module])

        scoped_names(action_name).values
      end.flatten.compact
    end

    def scoped_names(action_name)
      return unless ACTIONS_LIST.key?(action_name.to_sym)

      options = ACTIONS_LIST[action_name.to_sym]

      return { all: action_name } if options[:scopes].blank?

      options[:scopes].each_with_object({}) do |scope_name, names|
        names[scope_name] = "#{action_name}_#{scope_name}"
      end
    end

    def action_allowed?(admin:, action_name:, resource: nil)
      return true if admin.managing_user?
      return action_name.map { |single_name| action_allowed?(admin:, action_name: single_name, resource:) }.any? if action_name.is_a?(Array)

      action_scoped_names = scoped_names(action_name)

      # The action is not defined
      return false if action_scoped_names.blank?

      module_level_permissions = admin.permissions.where(namespace: "site_module", resource_type: module_name)

      # The action is allowed for all scope
      return true if module_level_permissions.where(action_name: action_scoped_names[:all]).exists?
      return false if resource.blank?

      assigned_resource_groups = admin.admin_groups.where(resource:)

      # Direct permissions: The assigned resource groups have permissions for
      # the action
      direct_permissions = GobiertoAdmin::GroupPermission
        .where(admin_group: assigned_resource_groups, namespace: module_name)
        .where("action_name LIKE ?", GobiertoAdmin::GroupPermission.sanitize_sql_like(action_name.to_s + "%"))

      return true if direct_permissions.exists?

      # Indirect permissions: The admin has been assigned to the resource as member
      # of its group and also belongs to a group with permission for the action
      # at assigned scope range
      assigned_resource_groups.present? &&
        action_scoped_names.key?(:assigned) &&
        module_level_permissions.where(action_name: action_scoped_names[:assigned]).exists?
    end
  end
end
