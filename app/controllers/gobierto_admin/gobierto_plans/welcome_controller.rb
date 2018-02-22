# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class WelcomeController < GobiertoAdmin::BaseController
      before_action { module_enabled!(current_site, "GobiertoPlans") }
      before_action { module_allowed!(current_admin, "GobiertoPlans") }

      def index
        @plans = current_site.plans
        @plan_types = ::GobiertoPlans::PlanType.all
        @archived_plan_types = ::GobiertoPlans::PlanType.only_archived
        @archived_plans = current_site.plans.only_archived

        @plan_form = GobiertoPlans::PlanForm.new(site_id: current_site.id)
        @plan_type_form = GobiertoPlans::PlanTypeForm.new
      end
    end
  end
end
