module GobiertoSites
  class SearchController < GobiertoSites::ApplicationController

    def all_categories
      year = params[:year].to_i
      place = INE::Places::Place.find_by_slug(params[:slug])

      query = params[:query].downcase
      suggestions = []
      [GobiertoBudgets::BudgetLine::ECONOMIC, GobiertoBudgets::BudgetLine::FUNCTIONAL].each do |area|
        [GobiertoBudgets::BudgetLine::EXPENSE, GobiertoBudgets::BudgetLine::INCOME].each do |kind|
          next if area == GobiertoBudgets::BudgetLine::FUNCTIONAL and kind == GobiertoBudgets::BudgetLine::INCOME

          this_year_codes = get_year_codes(place, area, kind, year)
          klass_name = area == 'economic' ? GobiertoBudgets::EconomicArea : GobiertoBudgets::FunctionalArea
          site = Site.find_by external_id: place.id
          suggestions += klass_name.all_items[kind].select{|k,v| this_year_codes.include?(k) && v.downcase.include?(query) }.map do |k,v|
            {
              value: v,
              data: {
                url: gobierto_sites_budget_line_url(year: year, id: k, kind: kind, area_name: area, host: site.domain)
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
