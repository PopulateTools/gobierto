# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class ProjectPolicy < ::GobiertoAdmin::BasePolicy
      attr_reader :project, :plan, :actions_manager

      # This constant maps the available controller actions of a project with
      # the admin actions defined in the actions manager
      ALLOWED_ACTIONS_MAPPING = {
        create_projects: [:index, :new, :create],
        view_projects: [:index, :show],
        edit_projects: [:index, :edit, :update], #, :update_attributes], TODO what happens with update_attributes?
        update_projects_as_minor_change: [:index, :edit, :update],
        moderate_projects: [:index, :edit, :moderate, :update],
        publish_projects: [:index, :edit, :publish, :unpublish, :update],
        delete_projects: [:index, :destroy],
        edit_projects_permissions: [:index, :show, :edit, :update],
        manage_plans: [:manage_plans, :index],
        manage_dashboards: [:index_dashboards, :manage_dashboards],
        view_dashboards: [:index_dashboards]
      }.freeze

      def self.scoped_admin_actions(controller_action, scope_name)
        controller_action = controller_action.to_sym
        scope_name = scope_name.to_sym

        ALLOWED_ACTIONS_MAPPING.filter_map do |admin_action_name, controller_actions|
          next unless controller_actions.include?(controller_action) && ::GobiertoPlans::AdminActionsManager::ACTIONS_LIST[admin_action_name].fetch(:scopes, []).include?(scope_name)

          "#{admin_action_name}_#{scope_name}".to_sym
        end
      end

      def self.controller_actions(*admin_action_names)
        ALLOWED_ACTIONS_MAPPING.slice(*admin_action_names).values.flatten.uniq
      end

      def initialize(attributes)
        super(attributes)
        @plan = attributes[:plan]
        @project = attributes[:project] || plan&.nodes || ::GobiertoPlans::Node.new
        @actions_manager = ::GobiertoAdmin::AdminActionsManager.for("gobierto_plans", current_site)
      end

      def scoped_admin_actions(*controller_action_names, scope: nil)
        ALLOWED_ACTIONS_MAPPING.filter_map do |admin_action, controller_actions|
          next if (controller_actions & controller_action_names).blank?

          scoped_names = actions_manager.scoped_names(admin_action)
          next scoped_names.values if scope.blank?

          scoped_names[scope]
        end.flatten
      end

      def allowed_to?(action)
        allowed_actions.include?(action)
      end

      def allowed_actions
        @allowed_actions ||= ALLOWED_ACTIONS_MAPPING.slice(*allowed_admin_actions).values.flatten.uniq
      end

      def allowed_admin_actions
        @allowed_admin_actions ||= actions_manager.action_names(scoped: false).select { |admin_action_name| can_perform_action_on_resource?(admin_action_name) }
      end

      def allowed_actions_by_scope(scope)
        ALLOWED_ACTIONS_MAPPING.slice(*allowed_admin_actions_by_scope(scope).map{ |name| name.to_s.gsub("_#{scope}", "").to_sym }).values.flatten.uniq
      end

      def allowed_admin_actions_by_scope(scope)
        actions_manager.action_names(scope:).select { |admin_action_name| can_perform_action_on_resource?(admin_action_name) }
      end

      private

      def can_perform_action_on_resource?(action)
        manage? || @actions_manager.action_allowed?(admin: current_admin, action_name: action, resource: project)
      end
    end
  end
end
