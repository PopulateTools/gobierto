# frozen_string_literal: true

module GobiertoPlans
  class AdminActionsManager < GobiertoAdmin::AdminActionsManager
    ACTIONS_LIST = {
      create_projects: {},
      view_projects: { scopes: [:all, :assigned] },
      edit_projects: { scopes: [:all, :assigned] },
      update_projects_as_minor_change: { scopes: [:all, :assigned] },
      moderate_projects: { scopes: [:all, :assigned] },
      publish_projects: { scopes: [:all, :assigned] },
      delete_projects: { scopes: [:all, :assigned] },
      edit_projects_permissions: { scopes: [:all, :assigned] },
      manage_plans: {},
      manage_dashboards: { module: "gobierto_dashboards" },
      view_dashboards: { module: "gobierto_dashboards" },
    }.freeze

    def action_names(scoped: true, scope: nil)
      scoped ||= scope.present?

      ACTIONS_LIST.map do |action_name, options|
        next unless options[:module].blank? || modules.include?(options[:module])
        next action_name unless scoped

        scope.present? ? scoped_names(action_name)[scope] : scoped_names(action_name).values
      end.flatten.compact
    end

    def admin_actions(admin:, resource:)
      all_action_names = action_names(scope: :all)

      if admin.managing_user?
        controller_actions = GobiertoAdmin::GobiertoPlans::ProjectPolicy::ALLOWED_ACTIONS_MAPPING.values.flatten.uniq
        return {
          default: {
            admin_actions: all_action_names,
            controller_actions:
          },
          collection: {
            admin_actions: all_action_names,
            controller_actions:
          }
        }
      end

      module_level_actions = module_level_permissions(admin).pluck(:action_name).map(&:to_sym)

      all_actions = all_action_names & module_level_actions
      assigned_actions = all_actions + action_names(scope: :assigned) & module_level_actions

      all_controller_actions = GobiertoAdmin::GobiertoPlans::ProjectPolicy.controller_actions(*all_actions.map { |name| unscoped_names(name) }.flatten)
      assigned_controller_actions = GobiertoAdmin::GobiertoPlans::ProjectPolicy.controller_actions(*assigned_actions.map { |name| unscoped_names(name) }.flatten)

      actions_list = {
        default: { admin_actions: all_actions, controller_actions: all_controller_actions },
        collection: { admin_actions: (all_actions + assigned_actions).uniq, controller_actions: (all_controller_actions + assigned_controller_actions).uniq }
      }

      if assigned_actions.present?
        assigned_resource_ids(admin:, resource:).each do |id|
          actions_list[id] = { admin_actions: assigned_actions, controller_actions: assigned_controller_actions }
        end
      end

      actions_list
    end

    def action_allowed?(admin:, action_name:, resource: nil)
      return true if admin.managing_user?
      return action_name.any? { |single_name| action_allowed?(admin:, action_name: single_name, resource:) } if action_name.is_a?(Array)

      assigned_resource_groups = resource.presence && admin.admin_groups.where(resource:)

      # Direct permissions: The assigned resource groups have permissions for
      # the action
      return true if direct_permissions(action_name:, groups: assigned_resource_groups).exists?

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


    def scoped_names(action_name)
      action_name = action_name.to_sym

      key = ACTIONS_LIST.find do |key, options|
        action_name == key || /\A#{key}_(#{options[:scopes]&.join("|")})\z/.match?(action_name.to_s)
      end&.first

      return if key.blank?

      options = ACTIONS_LIST[key]

      return { all: action_name } if options[:scopes].blank?

      names = options[:scopes].each_with_object({}) do |scope_name, names|
        names[scope_name] = "#{key}_#{scope_name}".to_sym
      end

      return names if action_name == key

      return names.select do |scope, name|
        name.to_sym == action_name
      end
    end

    def unscoped_names(*action_names)
      action_names.map do |action_name|
        scoped_names(action_name).map { |scope, name| name.to_s.gsub(/_#{scope}\z/, "").to_sym }
      end.flatten.uniq
    end

    private

    def assigned_resource_ids(admin:, resource:)
      return resource if admin.managing_user?

      assigned_resource_groups = resource.presence && admin.admin_groups.where(resource:)

      return [] if assigned_resource_groups.blank?

      if resource.is_a? ActiveRecord::Relation
        cache_key = [admin.cache_key, resource.cache_key].join("-")
        cache_data(cache_key) do
          assigned_resource_groups.pluck(:resource_id)
        end
      else
        [resource&.id]
      end
    end

    def direct_permissions(action_name:, groups:)
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
