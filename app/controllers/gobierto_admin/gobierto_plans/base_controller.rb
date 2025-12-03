# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class BaseController < GobiertoAdmin::BaseController
      before_action { module_enabled!(current_site, "GobiertoPlans") }
      before_action { module_allowed!(current_admin, "GobiertoPlans") }

      helper_method :gobierto_plans_plan_type_preview_url, :current_admin_can_manage_plans?, :current_admin_can_edit_projects?, :admin_projects_actions

      protected

      def current_admin_can_manage_plans?
        @can_manage_plans = admin_actions_manager.action_allowed?(admin: current_admin, action_name: :manage_plans)
      end

      def current_admin_can_edit_projects?(plan)
        admin_actions_manager.action_allowed?(admin: current_admin, action_name: ProjectPolicy.scoped_admin_actions(:edit, :assigned), resource: plan.nodes)
      end

      def gobierto_plans_plan_type_preview_url(plan, options = {})
        if plan.draft?
          options.merge!(preview_token: current_admin.preview_token)
        end
        gobierto_plans_plan_url(plan.plan_type.slug, plan.year, options)
      end

      def admin_projects_actions
        @admin_projects_actions ||= admin_actions_manager.admin_actions(admin: current_admin, resource: @plan.nodes) if @plan
      end
    end
  end
end
