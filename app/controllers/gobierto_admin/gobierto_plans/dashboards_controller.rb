# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class DashboardsController < GobiertoAdmin::GobiertoPlans::BaseController
      include GobiertoAdmin::DashboardsHelper

      before_action :plan

      helper_method :current_controller_allowed_actions, :dashboard_preview_path

      def current_controller_allowed_actions
        @current_controller_allowed_actions ||= DashboardPolicy.new(
          current_admin: current_admin,
          current_site: current_site,
          dashboard: @dashboard_form&.dashboard || @dashboard
        ).allowed_actions
      end

      def list
        @dashboards = base_relation
        @context = context_resource.to_global_id.to_s
        @data_pipe = "project_metrics"
        render("gobierto_admin/gobierto_dashboards/dashboards/list_modal", layout: request.xhr? ? false : "gobierto_admin/layouts/application")
      end

      def destroy
        dashboard = base_relation.find(params[:id])
        dashboard.destroy

        redirect_to admin_plans_plan_dashboards_path(plan), notice: t("gobierto_admin.gobierto_dashboards.dashboards.destroy.success")
      end

      protected

      def dashboard_preview_path(dashboard, options = {})
        plan = dashboard.context_resource

        return unless plan.is_a?(::GobiertoPlans::Plan)

        if plan.draft?
          options.merge!(preview_token: current_admin.preview_token)
        end

        gobierto_plans_plan_dashboards_path(slug: plan.plan_type.slug, year: plan.year, dashboard_id: dashboard.id, **options)
      end

      private

      def plan
        @plan = current_site.plans.find params[:plan_id]
      end
      alias context_resource plan

      def base_relation
        current_site.dashboards.for_context(@plan).order(id: :desc)
      end

      def raise_action_not_allowed
        redirection_path = current_controller_allowed_actions.include?(:index) ? admin_plans_plan_dashboards_path(@plan) : edit_admin_plans_plan_path(@plan)
        redirect_to(
          redirection_path,
          alert: t("gobierto_admin.module_helper.not_enabled")
        )
      end
    end
  end
end
