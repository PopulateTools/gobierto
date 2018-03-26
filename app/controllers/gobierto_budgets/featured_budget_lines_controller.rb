module GobiertoBudgets
  class FeaturedBudgetLinesController < GobiertoBudgets::ApplicationController
    def show
      @year = params[:year].to_i
      @area_name = GobiertoBudgets::FunctionalArea.area_name

      @kind = GobiertoBudgets::BudgetLine::EXPENSE
      results = GobiertoBudgets::BudgetLine.search({
          kind: @kind, year: @year, ine_code: current_site.organization_id,
          type: @area_name, range_hash: {
            level: {ge: 3},
            amount_per_inhabitant: { gt: 0 }
          }
      })['hits']

      @code = results.sample['code'] if results.any?

      if @code.present?
        render pick_template, layout: false
      else
        render head: :success
      end
    end

    private

    def pick_template
      params[:template] || 'show'
    end
  end
end
