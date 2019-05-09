# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class BaseController < GobiertoAdmin::BaseController
      before_action { module_enabled!(current_site, "GobiertoPlans") }
      before_action { module_allowed!(current_admin, "GobiertoPlans") }

      helper_method :gobierto_plans_plan_type_preview_url, :current_admin_can_manage_plans?

      protected

      def current_admin_can_manage_plans?
        @can_manage_plans = current_admin.module_allowed_action?(current_admin_module, current_site, :manage)
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
