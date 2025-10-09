# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class ProjectPolicy < ::GobiertoAdmin::BasePolicy
      attr_reader :project, :actions_manager

      # This constant maps the available controller actions of a project with
      # the actions defined in the actions manager
      ALLOWED_ACTIONS_MAPPING = {
        create_projects: [:index, :new, :create],
        view_projects: [:index, :show],
        edit_projects: [:index, :edit, :update], #, :update_attributes], TODO what happens with update_attributes?
        moderate_projects: [:index, :edit, :moderate],
        publish_projects: [:index, :edit, :publish],
        delete_projects: [:index, :edit, :destroy],
        manage: [:manage],
        manage_dashboards: [:index_dashboards, :manage_dashboards],
        view_dashboards: [:index_dashboards]
      }.freeze

      def initialize(attributes)
        super(attributes)
        @project = attributes[:project] || ::GobiertoPlans::Node.new
        @actions_manager = ::GobiertoAdmin::AdminActionsManager.for("gobierto_plans", current_site)
      end

      def allowed_to?(action)
        allowed_actions.include?(action)
      end

      def allowed_actions
        @allowed_actions ||= ALLOWED_ACTIONS_MAPPING.select { |admin_action_name, _| can_perform_action_on_resource? admin_action_name }.values.flatten.uniq
      end

      private

      def can_perform_action_on_resource?(action)
        manage? || @actions_manager.action_allowed?(admin: current_admin, action_name: action, resource: project)
      end
    end
  end
end
