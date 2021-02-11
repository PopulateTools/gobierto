# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoDashboards
    class DashboardsController < GobiertoAdmin::BaseController
      before_action { module_enabled!(current_site, "GobiertoDashboards") }
      before_action -> { module_allowed_action!(current_admin, "GobiertoPlans", [:manage_dashboards, :view_dashboards]) }

      layout false

      def modal; end
    end
  end
end
