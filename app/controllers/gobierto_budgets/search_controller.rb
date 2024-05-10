module GobiertoBudgets
  class SearchController < GobiertoBudgets::ApplicationController

    def all_categories
      year  = params[:year].to_i
      query = params[:query].downcase

      custom_categories_suggestions = get_suggestions_from_custom_categories(query, year)

      suggestions = custom_categories_suggestions[:suggestions]

      suggestions += get_suggestions_from_default_categories(custom_categories_suggestions[:selected_budget_lines], current_site.organization_id, year, query)

      respond_to do |format|
        format.json do
          render json: {
            suggestions: suggestions
          }.to_json
        end
      end
    end

    private

    def get_suggestions_from_custom_categories(query, year)
      suggestions = { suggestions: [], selected_budget_lines: [] }

      GobiertoBudgets::Category.where(site: current_site).each do |category|
        next if category.custom_name_translations.nil?

        names = category.custom_name_translations.values.compact

        suggestions[:suggestions] += names.select{|name| name.downcase[/.*#{query}.*/] }.map do |name|
          suggestions[:selected_budget_lines] << { code: category.code, kind: category.kind, area_name: category.area_name }
          build_new_suggestion(name, year, category.code, category.kind, category.area_name, @site.domain)
        end
      end

      suggestions
    end

    def get_suggestions_from_default_categories(selected_budget_lines, organization_id, year, query)
      suggestions = []

      BudgetArea.all_areas.each do |area|
        area.available_kinds.each do |kind|
          area_name = area.area_name
          this_year_codes = get_year_codes(organization_id, area_name, kind, year)

          suggested_categories = area.all_items[kind].select do |code, name|
            this_year_codes.include?(code) && name.downcase.include?(query) && !selected_budget_lines.include?({ code: code, kind: kind, area_name: area_name })
          end

          suggestions += suggested_categories.map do |code, name|
            build_new_suggestion(name, year, code, kind, area_name, @site.domain)
          end
        end
      end

      suggestions
    end

    def get_year_codes(organization_id, area, kind, year)
      query = {
        query: {
          filtered: {
            filter: {
              bool: {
                must: [
                  {term: { organization_id: organization_id }},
                  {term: { kind: kind}},
                  {term: { year: year }},
                ]
              }
            }
          }
        },
        size: 10_000
      }

      response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: area, body: query
      response['hits']['hits'].map{|h| h['_source']['code'] }
    end

    def build_new_suggestion(name, year, code, kind, area_name, host)
      {
        value: name,
        data: {
          url: gobierto_budgets_budget_line_url(year: year, id: code, kind: kind, area_name: area_name, host: host)
        }
      }
    end

  end
end
