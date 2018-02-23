# frozen_string_literal: true

module GobiertoPlans
  class PlansController < GobiertoPlans::ApplicationController
    include ::PreviewTokenHelper
    include User::SessionHelper

    before_action :load_plans, only: [:index, :show]

    def index
      # TODO: Pending adaptation to new plans
      redirect_to gobierto_plans_plan_path(id: @plans.last.slug)
    end

    def show
      @plan = find_plan

      @site_stats = GobiertoPlans::SiteStats.new site: @site, plan: @plan
      @plan_updated_at = @site_stats.plan_updated_at

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
                    level_keys: level_keys }
          )
        end
      end
    end

    private

    def find_plan
      @plans.find_by!(slug: params[:id])
    end

    def load_plans
      @plans = valid_preview_token? ? current_site.plans.draft : current_site.plans.sort_by_updated_at.published
    end

    def level_keys
      @plan.configuration_data.select { |k| k =~ /level\d\z/ }
    end
  end
end
