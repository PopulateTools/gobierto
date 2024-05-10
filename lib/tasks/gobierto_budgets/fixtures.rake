# frozen_string_literal: true

namespace :gobierto_budgets do
  namespace :fixtures do
    desc "Create indices and import data"
    task load: :environment do
      BUDGETS_INDEXES = [GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed].freeze
      BUDGETS_TYPES = GobiertoBudgets::BudgetArea.all_areas_names

      create_categories_index
      create_data_index

      create_categories_mapping
      create_data_mapping

      import_categories

      organizations = [INE::Places::Place.find_by_slug("madrid"), INE::Places::Place.find_by_slug("santander"), "wadus"]
      organizations.each do |organization|
        (GobiertoBudgets::SearchEngineConfiguration::Year.last - 2..GobiertoBudgets::SearchEngineConfiguration::Year.last).each do |year|
          import_gobierto_budgets_for_organization(organization, year)
          import_gobierto_budgets_data_for_organization(organization, year)
        end
      end
    end

    def import_gobierto_budgets_data_for_organization(organization, year)
      place, organization_id = resolve_place_and_organization_id(organization)

      index = GobiertoBudgets::SearchEngineConfiguration::Data.index
      data_for_organization = [GobiertoBudgets::SearchEngineConfiguration::Data.type_population, GobiertoBudgets::SearchEngineConfiguration::Data.type_debt].map do |type|
        {
          index: {
            _index: index,
            _id: [organization_id, year].join("/"),
            _type: type,
            data: {
              organization_id: organization_id,
              ine_code: place.id.to_i,
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
        GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
        GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed
      ].map do |index|
        categories_fixtures do |category|
          next if category["organization_id"] && (category["organization_id"] != organization_id)

          category["kind"] = category["kind"] == "income" ? "I" : "G"
          {
            index: {
              _index: index,
              _id: [organization_id, year, category["code"], category["kind"]].join("/"),
              _type: category["area"],
              data: base_data.merge(amount: rand(1_000_000),
                                    code: category["code"],
                                    level: category["level"],
                                    kind: category["kind"],
                                    amount_per_inhabitant: (rand(1_000) / 2.0).round(2),
                                    parent_code: category["parent_code"])
            }
          }
        end
      end.flatten.compact

      total_budgets = [
        GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
        GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed
      ].map do |index|
        type = GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type
        categories_fixtures do |category|
          category["kind"] = category["kind"] == "income" ? "I" : "G"
          {
            index: {
              _index: index,
              _id: [organization_id, year, category["kind"]].join("/"),
              _type: type,
              data: base_data.except(:population).merge(kind: category["kind"],
                                                        total_budget: rand(1_000_000),
                                                        total_budget_per_inhabitant: rand(1_000_000))
            }
          }
        end
      end.flatten

      economic_budget_lines_for_functional = []
      categories_fixtures do |category|
        next if category["organization_id"] && (category["organization_id"] != organization_id)
        next if category["area_name"] != "economic" && category["kind"] == "income"

        index = GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast
        category["kind"] = category["kind"] == "income" ? "I" : "G"
        economic_budget_lines_for_functional.push(index: {
                                                    _index: index,
                                                    _id: [organization_id, year, "#{ category["code"] }-1-f}", category["kind"]].join("/"),
                                                    _type: category["area"],
                                                    data: base_data.merge(amount: rand(1_000_000),
                                                                          code: category["code"],
                                                                          level: category["level"],
                                                                          kind: category["kind"],
                                                                          amount_per_inhabitant: (rand(1_000) / 2.0).round(2),
                                                                          functional_code: 1,
                                                                          parent_code: category["parent_code"])
                                                  })
      end

      economic_budget_lines_for_custom = []
      categories_fixtures do |category|
        next if category["organization_id"] && (category["organization_id"] != organization_id)
        next if category["area_name"] != "economic" && category["kind"] == "income"

        index = GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast
        category["kind"] = "G"
        economic_budget_lines_for_functional.push(index: {
                                                    _index: index,
                                                    _id: [organization_id, year, "#{category["code"]}-1-c", category["kind"]].join("/"),
                                                    _type: category["area"],
                                                    data: base_data.merge(amount: rand(1_000_000),
                                                                          code: category["code"],
                                                                          level: category["level"],
                                                                          kind: category["kind"],
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

    def create_categories_index
      index = GobiertoBudgets::SearchEngineConfiguration::BudgetCategories.index
      if GobiertoBudgets::SearchEngine.client.indices.exists? index: index
        GobiertoBudgets::SearchEngine.client.indices.delete index: index
      end
      GobiertoBudgets::SearchEngine.client.indices.create index: index
    end

    def create_data_index
      index = GobiertoBudgets::SearchEngineConfiguration::Data.index
      if GobiertoBudgets::SearchEngine.client.indices.exists? index: index
        GobiertoBudgets::SearchEngine.client.indices.delete index: index
      end
      GobiertoBudgets::SearchEngine.client.indices.create index: index
    end

    def create_categories_mapping
      m = GobiertoBudgets::SearchEngine.client.indices.get_mapping index: GobiertoBudgets::SearchEngineConfiguration::BudgetCategories.index, type: GobiertoBudgets::SearchEngineConfiguration::BudgetCategories.type
      return unless m.empty?

      puts "== Creating categories mapping =="
      GobiertoBudgets::SearchEngine.client.indices.put_mapping index: GobiertoBudgets::SearchEngineConfiguration::BudgetCategories.index, type: GobiertoBudgets::SearchEngineConfiguration::BudgetCategories.type, body: {
        GobiertoBudgets::SearchEngineConfiguration::BudgetCategories.type.to_sym => {
          properties: {
            area:        { type: "string", index: "not_analyzed" },
            code:        { type: "string", index: "not_analyzed" },
            name:        { type: "string", index: "not_analyzed" },
            parent_code: { type: "string", index: "not_analyzed" },
            level:       { type: "integer", index: "not_analyzed" },
            kind:        { type: "string", index: "not_analyzed" } # income I / expense G
          }
        }
      }
    end

    def import_categories
      puts "== Importing categories =="
      categories = categories_fixtures do |category|
        {
          index: {
            _index: GobiertoBudgets::SearchEngineConfiguration::BudgetCategories.index,
            _id: category.slice("organization_id", "area", "code", "kind").values.join("/"),
            _type: GobiertoBudgets::SearchEngineConfiguration::BudgetCategories.type,
            data: category
          }
        }
      end

      GobiertoBudgets::SearchEngine.client.bulk(body: categories)
    end

    def create_data_mapping
      index = GobiertoBudgets::SearchEngineConfiguration::Data.index
      [GobiertoBudgets::SearchEngineConfiguration::Data.type_population, GobiertoBudgets::SearchEngineConfiguration::Data.type_debt].each do |type|
        m = GobiertoBudgets::SearchEngine.client.indices.get_mapping index: index, type: type
        next unless m.empty?

        puts "== Creating data mapping =="
        GobiertoBudgets::SearchEngine.client.indices.put_mapping index: index, type: type, body: {
          type.to_sym => {
            properties: {
              organization_id: { type: "string", index: "not_analyzed" },
              ine_code:        { type: "integer", index: "not_analyzed" },
              province_id:     { type: "integer", index: "not_analyzed" },
              autonomy_id:     { type: "integer", index: "not_analyzed" },
              year:            { type: "integer", index: "not_analyzed" },
              value:           { type: "double", index: "not_analyzed" }
            }
          }
        }
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
