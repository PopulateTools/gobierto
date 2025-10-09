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

      assigned_resource_groups = resource.presence && admin.admin_groups.where(resource:)

      # Direct permissions: The assigned resource groups have permissions for
      # the action
      return true if direct_permisions(action_name:, groups: assigned_resource_groups).exists?

      action_scoped_names = scoped_names(action_name)

      # The action is not defined
      return false if action_scoped_names.blank?

      admin_module_level_permissions = module_level_permissions(admin)

      # Permissions associated to each scope
      action_scoped_names.each do |key, action_name|
        return true if admin_module_level_permissions.where(action_name:).exists? && extra_conditions(key, assigned_resource_groups: assigned_resource_groups)
      end

      false
    end

    private

    def direct_permisions(action_name:, groups:)
      GobiertoAdmin::GroupPermission
        .where(admin_group: groups, namespace: module_name)
        .where("action_name LIKE ?", GobiertoAdmin::GroupPermission.sanitize_sql_like(action_name.to_s + "%"))
    end

    def extra_conditions(key, context = {})
      case key
      when :all
        # The all scope does not have additional conditions
        true
      when :assigned
        # The admin must belong to at least one group of the resource
        context[:assigned_resource_groups].present?
      end
    end

    def module_level_permissions(admin)
      admin.permissions.where(namespace: "site_module", resource_type: module_name)
    end
  end
end
