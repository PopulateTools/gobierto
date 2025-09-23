# frozen_string_literal: true

module GobiertoPlans
  class PlanTypesController < GobiertoPlans::ApplicationController
    include ::PreviewTokenHelper
    include User::SessionHelper

    before_action :overrided_root_redirect, only: [:show]
    helper_method :dashboards_enabled?

    def index
      redirect_to GobiertoPlans.root_path(current_site)
    end

    def show
      @plan_type = find_plan_type
      load_plans
      load_years
      load_year
      @year ||= @years.first

      @plan = PlanDecorator.new(find_plan)
      @sdgs = SdgDecorator.new(find_plan)

      @site_stats = GobiertoPlans::SiteStats.new site: current_site, plan: @plan
      @plan_updated_at = @site_stats.plan_updated_at
    end

    def sdg
      @plan_type = find_plan_type
      last_year = @plan_type.plans.published.maximum(:year)
      load_year
      redirect_to gobierto_plans_plan_sdg_path(slug: params[:slug], year: last_year, sdg_slug: params[:sdg_slug]) and return if @year.nil?

      @plan = PlanDecorator.new(find_plan)
      @sdgs = SdgDecorator.new(find_plan)
      @sdg = @sdgs.sdg_term(params[:sdg_slug])
      @projects = @sdgs.projects_by_sdg(@sdg)
      @projects_term = @plan.level_key(2, @plan.levels + 1)
    end

    private

    def dashboards_enabled?
      @dashboards_enabled ||= module_enabled?("GobiertoDashboards") && defined?(GobiertoDashboards::Dashboard) && current_site.dashboards.active.for_context(@plan).exists?
    end

    def find_plan_type
      return PlanType.site_plan_types_with_years(current_site).first unless params[:slug]

      current_site.plan_types.find_by!(slug: params[:slug])
    end

    def find_plan
      valid_preview_token? ? @plan_type.plans.find_by!(year: @year) : @plan_type.plans.published.find_by!(year: @year)
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
