# frozen_string_literal: true

module GobiertoBudgets
  class BudgetTotalCalculator
    def initialize(site, year)
      @site = site
      @year = year
      @place_attributes = if (place = @site.place)
                            { ine_code: place.id.to_i,
                              province_id: place.province.id.to_i,
                              autonomy_id: place.province.autonomous_region.id.to_i }
                          else
                            { ine_code: nil,
                              province_id: nil,
                              autonomy_id: nil }
                          end
    end

    def calculate!
      GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::TotalBudget.all_indices.each do |index|
        import_total_budget(year, index, GobiertoBudgets::BudgetLine::EXPENSE)
        import_total_budget(year, index, GobiertoBudgets::BudgetLine::INCOME)
      end
    end

    private

    attr_reader :site, :year, :place_attributes

    def import_total_budget(year, index, kind)
      organization_id = site.organization_id

      total_budget, total_budget_per_inhabitant = get_data(index, organization_id, year, kind)
      if total_budget == 0.0 && kind == GobiertoBudgets::BudgetLine::EXPENSE
        total_budget, total_budget_per_inhabitant = get_data(index, organization_id, year, kind, GobiertoBudgets::EconomicArea.area_name)
      end

      data = place_attributes.merge({
        organization_id: organization_id,
        year: year,
        kind: kind,
        total_budget: total_budget.to_f,
        total_budget_per_inhabitant: total_budget_per_inhabitant.to_f
      })

      id = [organization_id, year, kind].join("/")
      GobiertoBudgets::SearchEngine.client.index index: index, type: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type, id: id, body: data
    end

    def get_data(index, organization_id, year, kind, type = nil)
      query = {
        query: {
          filtered: {
            query: {
              match_all: {}
            },
            filter: {
              bool: {
                must: [
                  { term: { organization_id: organization_id } },
                  { term: { level: 1 } },
                  { term: { kind: kind } },
                  { term: { year: year } },
                  { missing: { field: "functional_code" } },
                  { missing: { field: "custom_code" } }
                ]
              }
            }
          }
        },
        aggs: {
          total_budget: { sum: { field: "amount" } },
          total_budget_per_inhabitant: { sum: { field: "amount_per_inhabitant" } }
        },
        size: 0
      }

      type ||= kind == GobiertoBudgets::BudgetLine::EXPENSE ? GobiertoBudgets::FunctionalArea.area_name : GobiertoBudgets::EconomicArea.area_name

      result = GobiertoBudgets::SearchEngine.client.search index: index, type: type, body: query
      [result["aggregations"]["total_budget"]["value"].round(2), result["aggregations"]["total_budget_per_inhabitant"]["value"].round(2)]
    end
  end
end
