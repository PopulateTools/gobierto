namespace :gobierto_budgets do
  namespace :fixtures do
    desc "Create indices and import data"
    task load: :environment do
      BUDGETS_INDEXES = [GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed]
      BUDGETS_TYPES = ['economic', 'functional']

      create_categories_mapping
      create_data_mapping
      create_budgets_mapping

      import_categories
      place = INE::Places::Place.find_by_slug('madrid')
      (GobiertoBudgets::SearchEngineConfiguration::Year.last - 1..GobiertoBudgets::SearchEngineConfiguration::Year.last).each do |year|
        import_gobierto_budgets_for_place(place, year)
        import_gobierto_budgets_data_for_place(place, year)
      end
    end

    def import_gobierto_budgets_data_for_place(place, year)
      index = GobiertoBudgets::SearchEngineConfiguration::Data.index
      data_for_place = [GobiertoBudgets::SearchEngineConfiguration::Data.type_population, GobiertoBudgets::SearchEngineConfiguration::Data.type_debt].map do |type|
        {
          index: {
            _index: index,
            _id: [place.id, year].join('/'),
            _type: type,
            data: {
              ine_code: place.id, province_id: place.province_id,
              autonomy_id: place.province.autonomous_region_id,
              year: year, value: rand(1_000_000)
            }
          }
        }
      end

      GobiertoBudgets::SearchEngine.client.bulk(body: data_for_place)
    end

    def import_gobierto_budgets_for_place(place, year)
      puts "== Importing budgets for place #{place.name} in #{year} =="
      base_data = {
        ine_code: place.id.to_i, province_id: place.province.id.to_i,
        autonomy_id: place.province.autonomous_region.id.to_i, year: year,
        population: rand(1_000_000)
      }

      budgets_for_place = BUDGETS_INDEXES.map do |index|
        categories_fixtures do |category|
          category.merge!('kind' => category['kind'] == 'income' ? 'I' : 'G')
          {
            index: {
              _index: index,
              _id: [place.id, year, category['code'], category['kind']].join('/'),
              _type: category['area'],
              data: base_data.merge({
                amount: rand(1_000_000), code: category['code'],
                level: category['level'], kind: category['kind'],
                amount_per_inhabitant: (rand(1_000)/2.0).round(2),
                parent_code: category['parent_code']
              })
            }
          }
        end
      end.flatten

      total_budgets = BUDGETS_INDEXES.map do |index|
        type = GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type
        categories_fixtures do |category|
          category.merge!('kind' => category['kind'] == 'income' ? 'I' : 'G')
          {
            index: {
              _index: index,
              _id: [place.id, year, category['kind']].join("/"),
              _type: type,
              data: {
                ine_code: place.id.to_i, province_id: place.province.id.to_i,
                autonomy_id: place.province.autonomous_region.id.to_i, year: year,
                kind: category['kind'],
                total_budget: rand(1_000_000),
                total_budget_per_inhabitant: rand(1_000_000)
              }
            }
          }
        end
      end.flatten

      GobiertoBudgets::SearchEngine.client.bulk(body: budgets_for_place + total_budgets)
    end

    def categories_fixtures(&block)
      YAML.load(File.read(File.expand_path('categories.yml', __dir__))).map do |_, category|
        yield(category)
      end
    end

    def create_categories_mapping
      m = GobiertoBudgets::SearchEngine.client.indices.get_mapping index: GobiertoBudgets::SearchEngineConfiguration::BudgetCategories.index, type: GobiertoBudgets::SearchEngineConfiguration::BudgetCategories.type
      return unless m.empty?

      puts "== Creating categories mapping =="
      GobiertoBudgets::SearchEngine.client.indices.put_mapping index: GobiertoBudgets::SearchEngineConfiguration::BudgetCategories.index, type: GobiertoBudgets::SearchEngineConfiguration::BudgetCategories.type, body: {
        GobiertoBudgets::SearchEngineConfiguration::BudgetCategories.type.to_sym => {
          properties: {
            area:        { type: 'string',  index: 'not_analyzed' },
            code:        { type: 'string',  index: 'not_analyzed' },
            name:        { type: 'string',  index: 'not_analyzed' },
            parent_code: { type: 'string',  index: 'not_analyzed' },
            level:       { type: 'integer', index: 'not_analyzed' },
            kind:        { type: 'string',  index: 'not_analyzed' } # income I / expense G
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
            _id: category.slice('area', 'code', 'kind').values.join('/'),
            _type: GobiertoBudgets::SearchEngineConfiguration::BudgetCategories.type,
            data: category
          }
        }
      end

      GobiertoBudgets::SearchEngine.client.bulk(body: categories)
    end

    def create_budgets_mapping
      BUDGETS_INDEXES.each do |index|
        BUDGETS_TYPES.each do |type|
          m = GobiertoBudgets::SearchEngine.client.indices.get_mapping index: index, type: type
          return unless m.empty?

          puts "== Creating budgets mapping =="
          GobiertoBudgets::SearchEngine.client.indices.put_mapping index: index, type: type, body: {
            type.to_sym => {
              properties: {
                ine_code:              { type: 'integer', index: 'not_analyzed' },
                year:                  { type: 'integer', index: 'not_analyzed' },
                amount:                { type: 'double', index: 'not_analyzed'  },
                code:                  { type: 'string', index: 'not_analyzed'  },
                parent_code:           { type: 'string', index: 'not_analyzed'  },
                functional_code:       { type: 'string', index: 'not_analyzed'  },
                level:                 { type: 'integer', index: 'not_analyzed' },
                kind:                  { type: 'string', index: 'not_analyzed'  }, # income I / expense G
                province_id:           { type: 'integer', index: 'not_analyzed' },
                autonomy_id:           { type: 'integer', index: 'not_analyzed' },
                amount_per_inhabitant: { type: 'double', index: 'not_analyzed'  }
              }
            }
          }
        end

        type = GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type
        m = GobiertoBudgets::SearchEngine.client.indices.get_mapping index: index, type: type
        return unless m.empty?

        puts "== Creating total budgets mapping =="
        GobiertoBudgets::SearchEngine.client.indices.put_mapping index: index, type: type, body: {
          type.to_sym => {
            properties: {
              ine_code:                    { type: 'integer', index: 'not_analyzed' },
              province_id:                 { type: 'integer', index: 'not_analyzed' },
              autonomy_id:                 { type: 'integer', index: 'not_analyzed' },
              year:                        { type: 'integer', index: 'not_analyzed' },
              kind:                        { type: 'string', index: 'not_analyzed'  }, # income I / expense G
              total_budget:                { type: 'double',  index: 'not_analyzed' },
              total_budget_per_inhabitant: { type: 'double',  index: 'not_analyzed' }
            }
          }
        }
      end
    end

    def create_data_mapping
      index = GobiertoBudgets::SearchEngineConfiguration::Data.index
      [GobiertoBudgets::SearchEngineConfiguration::Data.type_population, GobiertoBudgets::SearchEngineConfiguration::Data.type_debt].each do |type|
        m = GobiertoBudgets::SearchEngine.client.indices.get_mapping index: index, type: type
        return unless m.empty?

        puts "== Creating data mapping =="
        GobiertoBudgets::SearchEngine.client.indices.put_mapping index: index, type: type, body: {
          type.to_sym => {
            properties: {
              ine_code:    { type: 'integer', index: 'not_analyzed' },
              province_id: { type: 'integer', index: 'not_analyzed' },
              autonomy_id: { type: 'integer', index: 'not_analyzed' },
              year:        { type: 'integer', index: 'not_analyzed' },
              value:       { type: 'double',  index: 'not_analyzed' }
            }
          }
        }
      end
    end
  end
end
