# frozen_string_literal: true

module GobiertoPlans
  class PlanTypesController < GobiertoPlans::ApplicationController
    include ::PreviewTokenHelper
    include User::SessionHelper

    def index
      # Select last plan published
      plan_types = current_site.plan_types
      @plan_type = plan_types.detect { |pt| pt.plans.published.any? }
      render_404 and return if @plan_type.nil?

      load_plans
      load_years

      redirect_to gobierto_plans_plan_path(slug: @plan_type.slug, year: @years.first)
    end

    def show
      @plan_type = find_plan_type
      load_plans
      load_years
      load_year
      redirect_to gobierto_plans_plan_path(slug: params[:slug], year: @years.first) and return if @year.nil?

      @plan = find_plan

      @site_stats = GobiertoPlans::SiteStats.new site: current_site, plan: @plan
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
                    level_keys: level_keys,
                    show_table_header: @plan.configuration_data["show_table_header"],
                    open_node: @plan.configuration_data["open_node"] }
          )
        end
      end
    end

    private

    def find_plan_type
      current_site.plan_types.find_by!(slug: params[:slug])
    end

    def find_plan
      valid_preview_token? ? @plan_type.plans.find_by!(year: params[:year]) : @plan_type.plans.published.find_by!(year: params[:year])
    end

    def level_keys
      @plan.configuration_data.select { |k| k =~ /level\d\z/ }
    end

    def load_plans
      @plans = @plan_type.plans.published
    end

    def load_years
      @years = @plans.pluck(:year).sort.reverse!
    end

    def load_year
      if params[:year]
        @year = params[:year].to_i
      end
    end
  end
end
