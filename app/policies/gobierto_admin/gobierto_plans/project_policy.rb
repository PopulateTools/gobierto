# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class ProjectPolicy < ::GobiertoAdmin::BasePolicy
      attr_reader :project

      ALLOWED_ACTIONS = { edit: [:index, :edit, :update, :new, :create, :destroy],
                          moderate: [:index, :edit, :update],
                          manage: [] }.freeze

      def initialize(attributes)
        super(attributes)
        @project = attributes[:project] || ::GobiertoPlans::Node.new
      end

      def edit?
        can_perform_action_on_resource? :edit
      end

      def destroy_action?
        manage? || edit? && (project.author.blank? || project.author == current_admin)
      end

      def allowed_actions
        default_actions = ALLOWED_ACTIONS.select { |admin_action_name, _| can_perform_action_on_resource? admin_action_name }.values.flatten.uniq
        default_actions.reject { |project_action| respond_to?("#{project_action}_action?") && !send("#{project_action}_action?") }
      end

      private

      def can_perform_action_on_resource?(action)
        manage? ||
          project.permissions_lookup_attributes(action).any? { |lookup_attributes| current_admin.permissions.where(lookup_attributes).exists? }
      end
    end
  end
end
