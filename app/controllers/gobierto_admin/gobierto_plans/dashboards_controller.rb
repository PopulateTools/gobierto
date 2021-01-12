# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class DashboardsController < GobiertoAdmin::GobiertoPlans::BaseController
      include GobiertoAdmin::DashboardsHelper

      before_action :plan

      helper_method :current_admin_actions

      def current_admin_actions
        @current_admin_actions ||= DashboardPolicy.new(
          current_admin: current_admin,
          current_site: current_site,
          dashboard: @dashboard_form&.dashboard || @dashboard
        ).allowed_actions
      end

      def list
        render("gobierto_admin/gobierto_dashboards/dashboards/list", layout: request.xhr? ? false : "gobierto_admin/layouts/application")
      end

      private

      def plan
        @plan = current_site.plans.find params[:plan_id]
      end
      alias context_resource plan

      def index_path
        @index_path ||= admin_plans_plan_dashboards_path(plan)
      end

      def base_relation
        current_site.dashboards.for_context(@plan)
      end

      def raise_action_not_allowed
        redirection_path = current_admin_actions.include?(:index) ? admin_plans_plan_dashboards_path(@plan) : edit_admin_plans_plan_path(@plan)
        redirect_to(
          redirection_path,
          alert: t("gobierto_admin.module_helper.not_enabled")
        )
      end
    end
  end
end
