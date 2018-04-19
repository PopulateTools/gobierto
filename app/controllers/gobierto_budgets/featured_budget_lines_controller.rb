module GobiertoBudgets
  class FeaturedBudgetLinesController < GobiertoBudgets::ApplicationController
    def show
      @year = params[:id].to_i
      @area_name = GobiertoBudgets::FunctionalArea.area_name

      @kind = GobiertoBudgets::BudgetLine::EXPENSE
      results = GobiertoBudgets::BudgetLine.search({
          kind: @kind, year: @year, organization_id: current_site.organization_id,
          type: @area_name, range_hash: {
            level: { ge: 3 },
            amount: { gt: 0 }
          }
      })['hits']

      if results.any?
        random_item = results.sample
        @code = random_item['code']
        @population = random_item['population']
        render pick_template, layout: false
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
