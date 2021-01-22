# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class DashboardPolicy < ::GobiertoAdmin::BasePolicy
      attr_reader :project

      ALLOWED_ACTIONS = { view_dashboards: [:index, :show],
                          manage_dashboards: [:index, :show, :edit, :update, :new, :create, :destroy] }.freeze

      def initialize(attributes)
        super(attributes)
        @dashboard = attributes[:dashboard] || current_site.dashboards.new
      end

      def allowed_actions
        ALLOWED_ACTIONS.select { |admin_action_name, _| can?(admin_action_name) }.values.flatten.uniq
      end

      def can?(action)
        manage? || current_admin.permissions.can?(action)
      end
    end
  end
end
