# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class BaseController < GobiertoAdmin::BaseController
      before_action { module_enabled!(current_site, "GobiertoPlans") }
      before_action { module_allowed!(current_admin, "GobiertoPlans") }

      helper_method :gobierto_plans_plan_type_preview_url, :current_admin_can_manage_plans?, :current_admin_can_edit_projects?

      protected

      def current_admin_can_manage_plans?
        @can_manage_plans = admin_actions_manager.action_allowed?(admin: current_admin, action_name: :manage)
      end

      def current_admin_can_edit_projects?(plan)
        @can_manage_plans = admin_actions_manager.action_allowed?(admin: current_admin, action_name: :edit_projects_assigned, resource: plan.nodes)
      end

      def gobierto_plans_plan_type_preview_url(plan, options = {})
        if plan.draft?
          options.merge!(preview_token: current_admin.preview_token)
        end
        gobierto_plans_plan_url(plan.plan_type.slug, plan.year, options)
      end
    end
  end
end
