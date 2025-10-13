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
        moderate_projects: [:index, :edit, :moderate, :update],
        publish_projects: [:index, :edit, :publish, :unpublish, :update],
        delete_projects: [:index, :edit, :destroy],
        manage: [:index, :show, :edit, :update],
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

      def initialize(attributes)
        super(attributes)
        @plan = attributes[:plan]
        @project = attributes[:project] || plan&.nodes || ::GobiertoPlans::Node.new
        @actions_manager = ::GobiertoAdmin::AdminActionsManager.for("gobierto_plans", current_site)
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

      def allowed_admin_actions_to(action_name)
        action_name = action_name.to_sym
        allowed_admin_actions.select { |admin_action_name| ALLOWED_ACTIONS_MAPPING[admin_action_name].include?(action_name) }
      end

      private

      def can_perform_action_on_resource?(action)
        manage? || @actions_manager.action_allowed?(admin: current_admin, action_name: action, resource: project)
      end
    end
  end
end
