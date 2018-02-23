# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class WelcomeController < GobiertoAdmin::GobiertoPlans::BaseController
      def index
        @plans = current_site.plans.sort_by_updated_at
        @plan_types = ::GobiertoPlans::PlanType.all.sort_by_updated_at
        @archived_plan_types = ::GobiertoPlans::PlanType.only_archived.sort_by_updated_at
        @archived_plans = current_site.plans.only_archived.sort_by_updated_at

        @plan_form = GobiertoPlans::PlanForm.new(site_id: current_site.id)
        @plan_type_form = GobiertoPlans::PlanTypeForm.new
      end
    end
  end
end
