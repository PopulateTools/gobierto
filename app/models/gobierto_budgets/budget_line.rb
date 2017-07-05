module GobiertoBudgets
  class BudgetLine < OpenStruct
    class RecordNotFound < StandardError; end
    class InvalidSearchConditions < StandardError; end

    include ActiveModel::Model

    INCOME  = 'I'
    EXPENSE = 'G'

    attr_reader(
      :type,
      :id,
      :ine_code,
      :place,
      :province_id,
      :autonomy_id,
      :year,
      :amount,
      :code,
      :level,
      :kind,
      :category,
      :site,
      :area,
      :amount_per_inhabitant,
      :parent_code,
      :name,
      :index,
      :description
    )

    @sort_attribute ||= 'code'
    @sort_order ||= 'asc'

    def self.all_kinds
      [INCOME, EXPENSE]
    end

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
        {missing: { field: 'custom_code'}},
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

      area     = BudgetArea.klass_for(@conditions[:area_name])

      response = GobiertoBudgets::SearchEngine.client.search(
        index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
        type: area.area_name,
        body: query
      )

      hits = response['hits']['hits']

      raise GobiertoBudgets::BudgetLine::RecordNotFound if hits.empty?

      GobiertoBudgets::BudgetLinePresenter.new(hits.first['_source'].merge(
        site: @conditions[:site],
        kind: @conditions[:kind],
        area: area
      ))
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
                                                             type: EconomicArea.area_name, body: query

      response['hits']['hits'].map{ |h| h['_source'] }.map do |row|
        next if row['functional_code'].length != 1
        area = GobiertoBudgets::FunctionalArea
        row['code'] = row['functional_code']

        GobiertoBudgets::BudgetLinePresenter.new(row.merge(kind: EXPENSE, area: area, site: @conditions[:site]))
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
        if @conditions[:area_name] == FunctionalArea.area_name
          @conditions[:area_name] = EconomicArea.area_name
          terms.push({term: { functional_code: @conditions[:functional_code] }})
        else
          @conditions[:area_name] = FunctionalArea.area_name
          return functional_codes_for_economic_budget_line(@conditions)
        end
      elsif @conditions[:custom_code]
        if @conditions[:area_name] == CustomArea.area_name
          @conditions[:area_name] = EconomicArea.area_name
          terms.push({term: { custom_code: @conditions[:custom_code] }})
        # else
        #   @conditions[:area_name] = CustomArea.area_name
        #   return functional_codes_for_economic_budget_line(@conditions)
        end
      else
        terms.push({missing: { field: 'functional_code'}})
        terms.push({missing: { field: 'custom_code'}})
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

      area = BudgetArea.klass_for(@conditions[:area_name])

      response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
                                                             type: area.area_name, body: query

      response['hits']['hits'].map{ |h| h['_source'] }.map do |row|
        GobiertoBudgets::BudgetLinePresenter.new(row.merge(
          site: @conditions[:site],
          kind: @conditions[:kind],
          area: area,
          total: response['aggregations']['total_budget']['value'],
          total_budget_per_inhabitant: response['aggregations']['total_budget_per_inhabitant']['value']
        ))
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

      response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: (options[:type] || EconomicArea.area_name), body: query

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
                    field: "functional_code",
                  },
                },
                must_not: {
                  exists: {
                    field: "custom_code",
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

      response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: (options[:type] || EconomicArea.area_name), body: query

      planned_results = response['hits']['hits'].map{ |h| h['_source'] }

      response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed, type: (options[:type] || EconomicArea.area_name), body: query

      executed_results = response['hits']['hits'].map{ |h| h['_source'] }

      results = {}
      planned_results.each do |p|
        if e = executed_results.detect{|e| e['code'] == p['code']}
          results[p['code']] = [p['amount'], e['amount'], ((e['amount'].to_f - p['amount'].to_f)/p['amount'].to_f) * 100]
        end
      end

      return results.sort{ |b, a| a[1][2] <=> b[1][2] }[0..15], results.sort{ |a, b| a[1][2] <=> b[1][2] }[0..15]
    end

    def self.algolia_index
      @algolia_index ||= begin
        index = Algolia::Index.new(search_index_name)
        index.set_settings({ attributesForFaceting: [ 'site_id' ] })
        index
      end
    end

    def self.validate_conditions(conditions)
      if conditions.has_key?(:kind)
        raise GobiertoBudgets::BudgetLine::InvalidSearchConditions unless all_kinds.include?(conditions[:kind])
      end
      if conditions.has_key?(:area_name)
        raise GobiertoBudgets::BudgetLine::InvalidSearchConditions unless BudgetArea.all_areas_names.include?(conditions[:area_name])
      end
    end
    private_class_method :validate_conditions

    def self.search_index_name
      "#{APP_CONFIG["site"]["name"]}_#{Rails.env}_#{self.name}"
    end

    def self.get_level(code)
      code_segments = code.split('-')
      code_segments.length == 1 ? code_segments.first.length : code_segments.first.length + 1
    end

    def self.get_parent_code(code)
      if get_level(code) == 1
        nil
      else
        code_segments = code.split('-')
        code_segments.length == 1 ? code_segments.first.chop : code_segments.first
      end
    end

    def self.get_population(ine_code, year)
      result = GobiertoBudgets::SearchEngine.client.get(
        index: GobiertoBudgets::SearchEngineConfiguration::Data.index,
         type: GobiertoBudgets::SearchEngineConfiguration::Data.type_population,
           id: "#{ine_code}/#{year}"
      )
      result['_source']['value']
    end

    # Example:
    # bl = GobiertoBudgets::BudgetLine.new(area_name: 'economic', site: Site.second, year: 2015, amount: 123.45, code: '1', kind: 'G', index: 'index_forecast')
    def initialize(params = {})
      @site     = params[:site]
      @index    = params[:index]
      @area     = BudgetArea.klass_for(params[:area_name])
      @kind     = params[:kind]
      @code     = params[:code]
      @year     = params[:year]
      @amount   = params[:amount].round(2)

      @place       = site.place
      @ine_code    = place.id.to_i
      @id          = "#{ine_code}/#{year}/#{code}/#{kind}"
      @category    = Category.find_by(site: site, area_name: area.area_name, kind: kind, code: code)
      @name        = get_name
      @description = get_description
      @province_id = place.province_id.to_i
      @autonomy_id = place.province.autonomous_region_id.to_i
      @level       = self.class.get_level(code)
      @parent_code = self.class.get_parent_code(code)
      @amount_per_inhabitant = (amount / population).round(2)
    end

    def elastic_search_index
      GobiertoBudgets::SearchEngineConfiguration::BudgetLine.send(index)
    end

    def algolia_id
      "#{index}/#{area.area_name}/#{ine_code}/#{year}/#{code}/#{kind}"
    end

    def population
      @population ||= self.class.get_population(ine_code, year)
    end

    def to_param
      { place_id: place_id, year: year, code: code, area_name: area.area_name, kind: kind }
    end

    def elasticsearch_as_json
      {
        ine_code: ine_code,
        province_id: province_id,
        autonomy_id: autonomy_id,
        year: year,
        population: population,
        amount: amount,
        code: code,
        level: level,
        kind: kind,
        amount_per_inhabitant: amount_per_inhabitant,
        parent_code: parent_code
      }
    end

    def algolia_as_json
      current_locale = I18n.locale
      attributes_translations = {}

      I18n.available_locales.each do |locale|
        I18n.locale = locale
        attributes_translations["name_#{locale}"] = get_name
        attributes_translations["description_#{locale}"] = get_description
      end

      I18n.locale = current_locale

      {
        objectID: algolia_id,
        index: index,
        type: area.area_name,
        site_id: site.id,
        ine_code: ine_code,
        year: year,
        code: code,
        kind: kind
      }.merge(attributes_translations)
    end

    # def category
    #   area = BudgetArea.klass_for(area_name)
    #   area.all_items[self.kind][self.code]
    # end

    def save
      result = GobiertoBudgets::SearchEngine.client.index(index: elastic_search_index, type: area.area_name, id: id, body: elasticsearch_as_json.to_json)
      saved = (result['_shards']['failed'] == 0)
      if saved
        self.class.algolia_index.add_object(algolia_as_json)
      end
      saved
    end

    def destroy
      self.class.algolia_index.delete_object(algolia_id)
      result = GobiertoBudgets::SearchEngine.client.delete(index: elastic_search_index, type: area.area_name, id: id)
      result['_shards']['failed'] == 0
    end

    private

    def get_name
      (category ? category.name : GobiertoBudgets::Category.default_name(area, kind, code))
    end

    def get_description
      (category ? category.description : GobiertoBudgets::Category.default_description(area, kind, code))
    end

  end
end
