module GobiertoBudgets
  class FeaturedBudgetLinesController < GobiertoBudgets::ApplicationController
    def show
      @year = params[:id].to_i
      @area_name = GobiertoBudgets::FunctionalArea.area_name

      @kind = GobiertoBudgets::BudgetLine::EXPENSE
      results = GobiertoBudgets::BudgetLine.search(
        kind: @kind, year: @year, organization_id: current_site.organization_id,
        type: @area_name, range_hash: {
          level: { gte: 3 },
          amount: { gt: 0 }
        },
        updated_forecast: false
      )['hits']

      if results.any?
        random_item = results.map do |r|
          id = (r.slice("organization_id", "year", "code", "kind").values + [@area_name]).join('/')
          GobiertoBudgets::BudgetLinePresenter.load(id, current_site)
        end.select{ |b| b.name.present? }.sample

        if random_item
          @code = random_item.code
          site_stats = GobiertoBudgets::SiteStats.new(site: current_site, year: @year)
          @population = site_stats.population
          render pick_template, layout: false
        else
          head :ok
        end
      else
        head :ok
      end
    end

    private

    def pick_template
      params[:template] || 'show'
    end
  end
end
