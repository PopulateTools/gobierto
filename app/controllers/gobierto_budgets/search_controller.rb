module GobiertoBudgets
  class SearchController < GobiertoBudgets::ApplicationController

    def all_categories
      year = params[:year].to_i
      place = INE::Places::Place.find_by_slug(params[:slug])

      query = params[:query].downcase
      suggestions = []
      [GobiertoBudgets::BudgetLine::BUDGET_AREAS[:economic].area_name, GobiertoBudgets::BudgetLine::BUDGET_AREAS[:functional].area_name].each do |area|
        [GobiertoBudgets::BudgetLine::BUDGET_KINDS[:expense], GobiertoBudgets::BudgetLine::BUDGET_KINDS[:income]].each do |kind|
          next if area == GobiertoBudgets::BudgetLine::BUDGET_AREAS[:functional].area_name and kind == GobiertoBudgets::BudgetLine::BUDGET_KINDS[:income]

          this_year_codes = get_year_codes(place, area, kind, year)
          klass_name = area == 'economic' ? GobiertoBudgets::EconomicArea : GobiertoBudgets::FunctionalArea
          suggestions += klass_name.all_items[kind].select{|k,v| this_year_codes.include?(k) && v.downcase.include?(query) }.map do |k,v|
            {
              value: v,
              data: {
                url: gobierto_budgets_budget_line_url(year: year, id: k, kind: kind, area_name: area, host: @site.domain)
              }
            }
          end
        end
      end

      respond_to do |format|
        format.json do
          render json: {
            suggestions: suggestions
          }.to_json
        end
      end
    end

    private

    def get_year_codes(place, area, kind, year)
      query = {
        query: {
          filtered: {
            filter: {
              bool: {
                must: [
                  {term: { ine_code: place.id }},
                  {term: { kind: kind}},
                  {term: { year: year }},
                ]
              }
            }
          }
        },
        size: 10_000
      }

      response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: area, body: query
      response['hits']['hits'].map{|h| h['_source']['code'] }
    end
  end
end
