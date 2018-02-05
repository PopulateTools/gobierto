# frozen_string_literal: true

module GobiertoPlans
  class PlansController < GobiertoPlans::ApplicationController
    include User::SessionHelper

    before_action :load_plans, only: [:index, :show]

    def index
      # TODO: Pending adaptation to new plans
      plan = current_site.plans.first
      redirect_to gobierto_plans_plan_path(id: plan.slug)
    end

    def show
      @plan = find_plan
      @node_number = GobiertoPlans::CategoriesNode.where(category_id: @plan.categories.pluck(:id)).pluck(:node_id).uniq.size

      @levels = @plan.categories.maximum("level")

      respond_to do |format|
        format.html
        format.json do
          plan_tree = GobiertoPlans::PlanTree.new(@plan).call

          render(
            json: { plan_tree: plan_tree }
          )
        end
      end
    end

    private

    def find_plan
      current_site.plans.find_by!(slug: params[:id])
    end

    def load_plans
      @plans = current_site.plans
    end
  end
end
