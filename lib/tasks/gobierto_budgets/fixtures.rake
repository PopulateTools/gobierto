# frozen_string_literal: true

namespace :gobierto_budgets do
  namespace :fixtures do
    desc "Create indices and import data"
    task load: :environment do
      BUDGETS_INDEXES = GobiertoBudgetsData::GobiertoBudgets::ALL_INDEXES
      BUDGETS_TYPES = GobiertoBudgetsData::GobiertoBudgets::ALL_TYPES

      organizations = [INE::Places::Place.find_by_slug("madrid"), INE::Places::Place.find_by_slug("santander"), "wadus"]
      organizations.each do |organization|
        (GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.last - 2..GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.last).each do |year|
          import_gobierto_budgets_for_organization(organization, year)
          import_gobierto_budgets_data_for_organization(organization, year)
        end
      end
    end

    def import_gobierto_budgets_data_for_organization(organization, year)
      place, organization_id = resolve_place_and_organization_id(organization)

      index = GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Data.index
      data_for_organization = [GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Data.type_population, GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Data.type_debt].map do |type|
        {
          index: {
            _index: index,
            _id: [organization_id, year, type].join("/"),
            data: {
              organization_id: organization_id,
              ine_code: place.id.to_i,
              type: type,
              province_id: place.province_id,
              autonomy_id: place.province.autonomous_region_id,
              year: year, value: rand(1_000_000)
            }
          }
        }
      end

      GobiertoBudgets::SearchEngine.client.bulk(body: data_for_organization)
    end

    def import_gobierto_budgets_for_organization(organization, year)
      place, organization_id = resolve_place_and_organization_id(organization)

      puts "== Importing budgets for organization #{ place.blank? ? organization_id : "Place: #{ place.name }" } in #{ year } =="
      base_data = {
        organization_id: organization_id,
        ine_code: place.id.to_i,
        province_id: place.province.id.to_i,
        autonomy_id: place.province.autonomous_region.id.to_i,
        year: year,
        population: rand(1_000_000)
      }

      budgets = [
        GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
        GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed
      ].map do |index|
        categories_fixtures do |category|
          next if category["organization_id"] && (category["organization_id"] != organization_id)

          category["kind"] = category["kind"] == "income" ? "I" : "G"
          {
            index: {
              _index: index,
              _id: [organization_id, year, category["code"], category["kind"], category["area"]].join("/"),
              data: base_data.merge(amount: rand(1_000_000),
                                    code: category["code"],
                                    type: category["area"],
                                    level: category["level"],
                                    kind: category["kind"],
                                    amount_per_inhabitant: (rand(1_000) / 2.0).round(2),
                                    parent_code: category["parent_code"])
            }
          }
        end
      end.flatten.compact

      total_budgets = [
        GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
        GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed
      ].map do |index|
        type = GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type
        categories_fixtures do |category|
          category["kind"] = category["kind"] == "income" ? "I" : "G"
          {
            index: {
              _index: index,
              _id: [organization_id, year, category["kind"], type].join("/"),
              data: base_data.except(:population).merge(kind: category["kind"],
                                                        type: type,
                                                        amount: rand(1_000_000),
                                                        amount_per_inhabitant: rand(1_000_000))
            }
          }
        end
      end.flatten

      economic_budget_lines_for_functional = []
      categories_fixtures do |category|
        next if category["organization_id"] && (category["organization_id"] != organization_id)
        next if category["area_name"] != "economic" && category["kind"] == "income"

        index = GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast
        category["kind"] = category["kind"] == "income" ? "I" : "G"
        economic_budget_lines_for_functional.push(index: {
                                                    _index: index,
                                                    _id: [organization_id, year, "#{ category["code"] }-1-f}", category["kind"], category["area"]].join("/"),
                                                    data: base_data.merge(amount: rand(1_000_000),
                                                                          code: category["code"],
                                                                          level: category["level"],
                                                                          kind: category["kind"],
                                                                          type: category["area"],
                                                                          amount_per_inhabitant: (rand(1_000) / 2.0).round(2),
                                                                          functional_code: 1,
                                                                          parent_code: category["parent_code"])
                                                  })
      end

      economic_budget_lines_for_custom = []
      categories_fixtures do |category|
        next if category["organization_id"] && (category["organization_id"] != organization_id)
        next if category["area_name"] != "economic" && category["kind"] == "income"

        index = GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast
        category["kind"] = "G"
        economic_budget_lines_for_functional.push(index: {
                                                    _index: index,
                                                    _id: [organization_id, year, "#{category["code"]}-1-c", category["kind"], category["area"]].join("/"),
                                                    data: base_data.merge(amount: rand(1_000_000),
                                                                          code: category["code"],
                                                                          level: category["level"],
                                                                          kind: category["kind"],
                                                                          type: category["area"],
                                                                          amount_per_inhabitant: (rand(1_000) / 2.0).round(2),
                                                                          custom_code: 1,
                                                                          parent_code: category["parent_code"])
                                                  })
      end

      GobiertoBudgets::SearchEngine.client.bulk(body: budgets + total_budgets + economic_budget_lines_for_functional + economic_budget_lines_for_custom)
    end

    def categories_fixtures
      YAML.safe_load(File.read(File.expand_path("categories.yml", __dir__))).map do |_, category|
        yield(category)
      end
    end

    def resolve_place_and_organization_id(organization)
      if organization.is_a? INE::Places::Place
        [organization, organization.id]
      else
        [NullObjectPlace.new, organization]
      end
    end

    class NullObjectPlace
      [:a, :s, :f, :i].each do |type|
        define_method :"to_#{type}" do
          nil
        end
      end

      def tap
        self
      end

      def nil?
        true
      end

      def present?
        false
      end

      def empty?
        true
      end

      def method_missing(*)
        self
      end
    end
  end
end
