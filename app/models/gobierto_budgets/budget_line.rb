module GobiertoBudgets
  class BudgetLine < OpenStruct
    class RecordNotFound < StandardError; end
    class InvalidSearchConditions < StandardError; end

    # Kinds
    INCOME = 'I'
    EXPENSE = 'G'
    # Areas / ElasticSearch types
    ECONOMIC = 'economic'
    FUNCTIONAL = 'functional'

    @sort_attribute ||= 'code'
    @sort_order ||= 'asc'

    def self.where(conditions)
      validate_conditions(conditions)
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

      raise GobiertoBudgets::BudgetLine::RecordNotFound if response['hits']['hits'].empty?
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
        {term: { ine_code: @conditions[:place].id }}
      ]

      terms.push({term: { year: @conditions[:year] }}) if @conditions[:year]
      terms.push({term: { code: @conditions[:code] }}) if @conditions[:code]
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

    def self.for_ranking(options)
      response = budget_line_query(options)
      results = response['hits']['hits'].map{|h| h['_source']}
      total_elements = response['hits']['total']

      return results, total_elements
    end

    def self.place_position_in_ranking(options)
      id = %w{ine_code year code kind}.map {|f| options[f.to_sym]}.join('/')

      response = budget_line_query(options.merge(to_rank: true))
      buckets = response['hits']['hits'].map{|h| h['_id']}
      position = buckets.index(id) ? buckets.index(id) + 1 : 0;
      return position
    end

    def self.budget_line_query(options)

      terms = [
        {term: { year: options[:year] }},
        {term: { kind: options[:kind] }},
        {term: { code: options[:code] }}
      ]

      if options[:filters].present?
        population_filter =  options[:filters][:population]
        total_filter = options[:filters][:total]
        per_inhabitant_filter = options[:filters][:per_inhabitant]
        aarr_filter = options[:filters][:aarr]
      end

      if (population_filter && (population_filter[:from].to_i > GobiertoBudgets::Population::FILTER_MIN || population_filter[:to].to_i < GobiertoBudgets::Population::FILTER_MAX))
        reduced_filter = {population: population_filter}
        reduced_filter.merge!(aarr: aarr_filter) if aarr_filter
        results,total_elements = GobiertoBudgets::Population.for_ranking(options[:year], 0, nil, reduced_filter)
        ine_codes = results.map{|p| p['ine_code']}
        terms << [{terms: { ine_code: ine_codes }}] if ine_codes.any?
      end

      if (total_filter && (total_filter[:from].to_i > GobiertoBudgets::BudgetTotal::TOTAL_FILTER_MIN || total_filter[:to].to_i < GobiertoBudgets::BudgetTotal::TOTAL_FILTER_MAX))
        terms << {range: { amount: { gte: total_filter[:from].to_i, lte: total_filter[:to].to_i} }}
      end

      if (per_inhabitant_filter && (per_inhabitant_filter[:from].to_i > GobiertoBudgets::BudgetTotal::PER_INHABITANT_FILTER_MIN || per_inhabitant_filter[:to].to_i < GobiertoBudgets::BudgetTotal::PER_INHABITANT_FILTER_MAX))
        terms << {range: { amount_per_inhabitant: { gte: per_inhabitant_filter[:from].to_i, lte: per_inhabitant_filter[:to].to_i} }}
      end

      terms << {term: { autonomy_id: aarr_filter }}  unless aarr_filter.blank?

      query = {
        sort: [ { options[:variable].to_sym => { order: 'desc' } } ],
        query: {
          filtered: {
            filter: {
              bool: {
                must: terms,
                must_not: {
                  exists: {
                    field: "functional_code"
                  }
                }
              }
            }
          }
        },
        size: 10_000
      }

      query.merge!(size: options[:per_page]) if options[:per_page].present?
      query.merge!(from: options[:offset]) if options[:offset].present?
      query.merge!(_source: false) if options[:to_rank]

      GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: options[:area_name], body: query
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

    def self.validate_conditions(conditions)
      if conditions.has_key?(:kind)
        raise GobiertoBudgets::BudgetLine::InvalidSearchConditions unless [INCOME, EXPENSE].include?(conditions[:kind])
      end
      if conditions.has_key?(:area_name)
        raise GobiertoBudgets::BudgetLine::InvalidSearchConditions unless [ECONOMIC, FUNCTIONAL].include?(conditions[:area_name])
      end
    end
    private_class_method :validate_conditions

  end
end
