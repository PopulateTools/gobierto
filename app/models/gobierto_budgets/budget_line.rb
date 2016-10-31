module GobiertoBudgets
  class BudgetLine < OpenStruct
    INCOME = 'I'
    EXPENSE = 'G'
    ECONOMIC = 'economic'
    FUNCTIONAL = 'functional'

    @sort_attribute ||= 'code'
    @sort_order ||= 'asc'

    def self.where(conditions)
      @conditions = conditions
      self
    end

    def self.first
      terms = [
        {term: { kind: @conditions[:kind] }},
        {term: { year: @conditions[:year] }},
        {term: { code: @conditions[:code] }},
        {missing: { field: 'functional_code'}},
        {term: { ine_code: @conditions[:place].id }}
      ]

      query = {
        sort: [
          { @sort_attribute => { order: @sort_order } }
        ],
        query: {
          filtered: {
            filter: {
              bool: {
                must: terms
              }
            }
          }
        },
        size: 10_000
      }

      if @conditions[:area_name] == GobiertoBudgets::BudgetLine::ECONOMIC
        area = GobiertoBudgets::EconomicArea
      else
        area = GobiertoBudgets::FunctionalArea
      end

      response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
                                                             type: @conditions[:area_name], body: query

      BudgetLinePresenter.new response['hits']['hits'].first['_source'].merge({kind: @conditions[:kind], area_name: @conditions[:area_name], area: area})
    end

    def self.functional_codes_for_economic_budget_line(conditions)
      terms = [
        {term: { kind: conditions[:kind] }},
        {term: { year: conditions[:year] }},
        {term: { code: conditions[:functional_code] }},
        {exists: { field: 'functional_code'}},
        {term: { ine_code: conditions[:place].id }}
      ]

      query = {
        sort: [
          { @sort_attribute => { order: @sort_order } }
        ],
        query: {
          filtered: {
            filter: {
              bool: {
                must: terms
              }
            }
          }
        },
        aggs: {
          total_budget: { sum: { field: 'amount' } },
          total_budget_per_inhabitant: { sum: { field: 'amount_per_inhabitant' } },
        },
        size: 10_000
      }

      response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
                                                             type: ECONOMIC, body: query

      response['hits']['hits'].map{ |h| h['_source'] }.map do |row|
        next if row['functional_code'].length != 1
        area = GobiertoBudgets::FunctionalArea
        row['code'] = row['functional_code']

        BudgetLinePresenter.new(row.merge({ kind: EXPENSE, area_name: FUNCTIONAL, area: area }))
      end.compact.sort{|b,a| a.amount <=> b.amount }
    end

    def self.all
      terms = [
        {term: { kind: @conditions[:kind] }},
        {term: { year: @conditions[:year] }},
        {term: { ine_code: @conditions[:place].id }}
      ]

      terms.push({term: { level: @conditions[:level] }}) if @conditions[:level]
      terms.push({term: { parent_code: @conditions[:parent_code] }}) if @conditions[:parent_code]
      if @conditions[:functional_code]
        if @conditions[:area_name] == FUNCTIONAL
          @conditions[:area_name] = ECONOMIC
          terms.push({term: { functional_code: @conditions[:functional_code] }})
        else
          @conditions[:area_name] = FUNCTIONAL
          return functional_codes_for_economic_budget_line(@conditions)
        end
      else
        terms.push({missing: { field: 'functional_code'}})
      end

      query = {
        sort: [
          { @sort_attribute => { order: @sort_order } }
        ],
        query: {
          filtered: {
            filter: {
              bool: {
                must: terms
              }
            }
          }
        },
        aggs: {
          total_budget: { sum: { field: 'amount' } },
          total_budget_per_inhabitant: { sum: { field: 'amount_per_inhabitant' } },
        },
        size: 10_000
      }

      if @conditions[:area_name] == ECONOMIC
        area = GobiertoBudgets::EconomicArea
      else
        area = GobiertoBudgets::FunctionalArea
      end

      response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
                                                             type: @conditions[:area_name], body: query

      response['hits']['hits'].map{ |h| h['_source'] }.map do |row|
        BudgetLinePresenter.new(row.merge({
          kind: @conditions[:kind], area_name: @conditions[:area_name], area: area, total: response['aggregations']['total_budget']['value'],
          total_budget_per_inhabitant: response['aggregations']['total_budget_per_inhabitant']['value']
        }))
      end
    end

    def self.search(options)

      terms = [{term: { kind: options[:kind] }},
              {term: { year: options[:year] }}]

      terms << {term: { ine_code: options[:ine_code] }} if options[:ine_code].present?
      terms << {term: { parent_code: options[:parent_code] }} if options[:parent_code].present?
      terms << {term: { level: options[:level] }} if options[:level].present?
      terms << {term: { code: options[:code] }} if options[:code].present?
      if options[:range_hash].present?
        options[:range_hash].each_key do |range_key|
          terms << {range: { range_key => options[:range_hash][range_key] }}
        end
      end

      query = {
        sort: [
          { code: { order: 'asc' } }
        ],
        query: {
          filtered: {
            filter: {
              bool: {
                must: terms
              }
            }
          }
        },
        aggs: {
          total_budget: { sum: { field: 'amount' } },
          total_budget_per_inhabitant: { sum: { field: 'amount_per_inhabitant' } },
        },
        size: 10_000
      }

      response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: (options[:type] || 'economic'), body: query

      return {
        'hits' => response['hits']['hits'].map{ |h| h['_source'] },
        'aggregations' => response['aggregations']
      }
    end

    def self.find(options)
      return self.search(options)['hits'].detect{|h| h['code'] == options[:code] }
    end

    def self.compare(options)
      terms = [{terms: { ine_code: options[:ine_codes] }},
               {term: { level: options[:level] }},
               {term: { kind: options[:kind] }},
               {term: { year: options[:year] }}]

      terms << {term: { parent_code: options[:parent_code] }} if options[:parent_code].present?
      terms << {term: { code: options[:code] }} if options[:code].present?

      query = {
        sort: [
          { code: { order: 'asc' } },
          { ine_code: { order: 'asc' }}
        ],
        query: {
          filtered: {
            filter: {
              bool: {
                must: terms
              }
            }
          }
        },
        size: 10_000
      }

      response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: options[:type] , body: query
      response['hits']['hits'].map{ |h| h['_source'] }
    end

    def self.has_children?(options)
      options.symbolize_keys!
      conditions = { parent_code: options[:code], level: options[:level].to_i + 1, type: options[:area] }
      conditions.merge! options.slice(:ine_code,:kind,:year)

      return search(conditions)['hits'].length > 0
    end

    def self.top_differences(options)
      terms = [{term: { kind: options[:kind] }}, {term: { year: options[:year] }}, {term: { level: 3 }}]
      terms << {term: { ine_code: options[:ine_code] }} if options[:ine_code].present?
      terms << {term: { code: options[:code] }} if options[:code].present?

      query = {
        sort: [
          { code: { order: 'asc' } }
        ],
        query: {
          filtered: {
            filter: {
              bool: {
                must: terms
              }
            }
          }
        },
        size: 10_000
      }

      response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: (options[:type] || 'economic'), body: query

      planned_results = response['hits']['hits'].map{ |h| h['_source'] }

      response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed, type: (options[:type] || 'economic'), body: query

      executed_results = response['hits']['hits'].map{ |h| h['_source'] }

      results = {}
      planned_results.each do |p|
        if e = executed_results.detect{|e| e['code'] == p['code']}
          results[p['code']] = [p['amount'], e['amount'], ((e['amount'].to_f - p['amount'].to_f)/p['amount'].to_f) * 100]
        end
      end

      return results.sort{ |b, a| a[1][2] <=> b[1][2] }[0..15], results.sort{ |a, b| a[1][2] <=> b[1][2] }[0..15]
    end

    def to_param
      {place_id: place_id, year: year, code: code, area_name: area_name, kind: kind}
    end

    def place
      if place_id
        INE::Places::Place.find(place_id)
      end
    end

    def category
      area = area_name == 'economic' ? EconomicArea : FunctionalArea
      area.all_items[self.kind][self.code]
    end
  end
end
