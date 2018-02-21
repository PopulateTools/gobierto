# frozen_string_literal: true

module GobiertoPlans
  class PlansController < GobiertoPlans::ApplicationController
    include User::SessionHelper

    before_action :load_plans, only: [:index, :show]

    def index
      # TODO: Pending adaptation to new plans
      redirect_to gobierto_plans_plan_path(id: @plans.first.slug)
    end

    def show
      @plan = find_plan

      respond_to do |format|
        format.html do
          @node_number = @plan.nodes.count
          @levels = @plan.levels
        end

        format.json do
          plan_tree = GobiertoPlans::PlanTree.new(@plan).call

          render(
            json: { plan_tree: plan_tree,
                    option_keys: @plan.configuration_data["option_keys"],
                    level_keys: level_keys,
                    show_table_header: @plan.configuration_data["show_table_header"],
                    open_node: @plan.configuration_data["open_node"] }
          )
        end
      end
    end

    private

    def find_plan
      @plans.find_by!(slug: params[:id])
    end

    def load_plans
      @plans = current_site.plans
    end

    def level_keys
      @plan.configuration_data.select { |k| k =~ /level\d\z/ }
    end
  end
end
