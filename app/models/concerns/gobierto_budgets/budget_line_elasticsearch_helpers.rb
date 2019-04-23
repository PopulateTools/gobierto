module GobiertoBudgets
  module BudgetLineElasticsearchHelpers
    extend ActiveSupport::Concern

    class_methods do

      SORT_ATTRIBUTE = 'code'
      SORT_ORDER     = 'asc'

      def first(params = {})
        conditions = params[:where]
        validate_conditions(conditions)

        terms = [
          {term: { kind: conditions[:kind] }},
          {term: { year: conditions[:year] }},
          {term: { code: conditions[:code] }},
          {missing: { field: 'functional_code'}},
          {missing: { field: 'custom_code'}},
          {term: { organization_id: conditions[:site].organization_id }}
        ]

        query = {
          sort: [
            { SORT_ATTRIBUTE => { order: SORT_ORDER } }
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

        area     = BudgetArea.klass_for(conditions[:area_name])

        response = SearchEngine.client.search(
          index: SearchEngineConfiguration::BudgetLine.index_forecast,
          type: area.area_name,
          body: query
        )

        hits = response['hits']['hits']

        raise BudgetLine::RecordNotFound if hits.empty?

        BudgetLinePresenter.new(hits.first['_source'].merge(
          site: conditions[:site],
          kind: conditions[:kind],
          area: area
        ))
      end

      def functional_codes_for_economic_budget_line(params = {})
        conditions = params[:where]
        validate_conditions(conditions)

        terms = [
          {term: { kind: conditions[:kind] }},
          {term: { year: conditions[:year] }},
          {term: { code: conditions[:functional_code] }},
          {exists: { field: 'functional_code'}},
          {term: { organization_id: conditions[:site].organization_id }}
        ]

        query = {
          sort: [
            { SORT_ATTRIBUTE => { order: SORT_ORDER } }
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

        response = SearchEngine.client.search index: SearchEngineConfiguration::BudgetLine.index_forecast,
                                                               type: EconomicArea.area_name, body: query

        response['hits']['hits'].map{ |h| h['_source'] }.map do |row|
          next if row['functional_code'].length != 1
          area = FunctionalArea
          row['code'] = row['functional_code']

          BudgetLinePresenter.new(row.merge(kind: EXPENSE, area: area, site: conditions[:site]))
        end.compact.sort{|b,a| a.amount <=> b.amount }
      end

      def all(params = {})
        conditions = params[:where]
        includes = params[:include]
        presenter = params[:presenter] || BudgetLinePresenter
        updated_forecast = params[:updated_forecast] || false
        validate_conditions(conditions)

        terms = [
          {term: { kind: conditions[:kind] }},
          {term: { organization_id: conditions[:site].organization_id }}
        ]

        terms.push({term: { year: conditions[:year] }}) if conditions[:year]
        terms.push({term: { code: conditions[:code] }}) if conditions[:code]
        terms.push({term: { level: conditions[:level] }}) if conditions[:level]
        terms.push({term: { parent_code: conditions[:parent_code] }}) if conditions[:parent_code]
        if conditions[:functional_code]
          if conditions[:area_name] == FunctionalArea.area_name
            conditions[:area_name] = EconomicArea.area_name
            terms.push({term: { functional_code: conditions[:functional_code] }})
          else
            conditions[:area_name] = FunctionalArea.area_name
            return functional_codes_for_economic_budget_line(conditions)
          end
        elsif conditions[:custom_code]
          if conditions[:area_name] == CustomArea.area_name
            conditions[:area_name] = EconomicArea.area_name
            terms.push({term: { custom_code: conditions[:custom_code] }})
          # else
          #   conditions[:area_name] = CustomArea.area_name
          #   return functional_codes_for_economic_budget_line(conditions)
          end
        else
          terms.push({missing: { field: 'functional_code'}})
          terms.push({missing: { field: 'custom_code'}})
        end

        query = {
          sort: [
            { SORT_ATTRIBUTE => { order: SORT_ORDER } }
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

        area = BudgetArea.klass_for(conditions[:area_name])

        default_index = SearchEngineConfiguration::BudgetLine.index_forecast

        index = if updated_forecast
                  SearchEngineConfiguration::BudgetLine.index_forecast_updated
                else
                  conditions[:index] || default_index
                end

        response = SearchEngine.client.search(index: index, type: area.area_name, body: query)

        if updated_forecast && response["hits"]["hits"].empty?
          response = SearchEngine.client.search(index: default_index, type: area.area_name, body: query)
        end

        included_attrs = {}
        if includes.present?
          included_attrs[:index] = index if includes.include? :index
          included_attrs[:updated_at] = if includes.include?(:updated_at) && conditions[:year] && conditions[:site]
                                          GobiertoBudgets::SiteStats.new(site: conditions[:site], year: conditions[:year]).budgets_data_updated_at ||
                                            Date.new(conditions[:year])
                                        end
        end

        merge_includes = included_attrs.present? ? ->(row) { row.merge(included_attrs) } : ->(row) { row }

        response['hits']['hits'].map{ |h| h['_source'] }.map do |row|
          presenter.new(merge_includes.call(row.merge(
            site: conditions[:site],
            kind: conditions[:kind],
            area: area,
            total: response['aggregations']['total_budget']['value'],
            total_budget_per_inhabitant: response['aggregations']['total_budget_per_inhabitant']['value']
          )))
        end
      rescue Elasticsearch::Transport::Transport::Errors::NotFound
        return []
      end

      def search(options)
        updated_forecast = options.delete(:updated_forecast)
        terms = [{term: { kind: options[:kind] }},
                {term: { year: options[:year] }}]

        terms << {term: { organization_id: options[:organization_id] }} if options[:organization_id].present?
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

        default_index = SearchEngineConfiguration::BudgetLine.index_forecast
        index = updated_forecast ? SearchEngineConfiguration::BudgetLine.index_forecast_updated : default_index

        response = SearchEngine.client.search(index: index, type: (options[:type] || EconomicArea.area_name), body: query)

        if response["hits"]["hits"].empty?
          response = SearchEngine.client.search(index: default_index, type: (options[:type] || EconomicArea.area_name), body: query)
        end

        return {
          'hits' => response['hits']['hits'].map{ |h| h['_source'] },
          'aggregations' => response['aggregations']
        }
      end

      def for_ranking(options)
        response = budget_line_query(options)
        results = response['hits']['hits'].map{|h| h['_source']}
        total_elements = response['hits']['total']

        return results, total_elements
      end

      def place_position_in_ranking(options)
        id = %w{organization_id year code kind}.map {|f| options[f.to_sym]}.join('/')

        response = budget_line_query(options.merge(to_rank: true))
        buckets = response['hits']['hits'].map{|h| h['_id']}
        position = buckets.index(id) ? buckets.index(id) + 1 : 0;
        return position
      end

      def budget_line_query(options)

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

        if (population_filter && (population_filter[:from].to_i > Population::FILTER_MIN || population_filter[:to].to_i < Population::FILTER_MAX))
          reduced_filter = {population: population_filter}
          reduced_filter.merge!(aarr: aarr_filter) if aarr_filter
          results,total_elements = Population.for_ranking(options[:year], 0, nil, reduced_filter)
          organization_ids = results.map{|p| p['organization_id']}
          terms << [{terms: { organization_id: organization_id }}] if organization_ids.any?
        end

        if (total_filter && (total_filter[:from].to_i > BudgetTotal::TOTAL_FILTER_MIN || total_filter[:to].to_i < BudgetTotal::TOTAL_FILTER_MAX))
          terms << {range: { amount: { gte: total_filter[:from].to_i, lte: total_filter[:to].to_i} }}
        end

        if (per_inhabitant_filter && (per_inhabitant_filter[:from].to_i > BudgetTotal::PER_INHABITANT_FILTER_MIN || per_inhabitant_filter[:to].to_i < BudgetTotal::PER_INHABITANT_FILTER_MAX))
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

        SearchEngine.client.search index: SearchEngineConfiguration::BudgetLine.index_forecast, type: options[:area_name], body: query
      end

      def find(options)
        return self.search(options)['hits'].detect{|h| h['code'] == options[:code] }
      end

      def compare(options)
        terms = [{terms: { organization_id: options[:organization_ids] }},
                 {term: { level: options[:level] }},
                 {term: { kind: options[:kind] }},
                 {term: { year: options[:year] }}]

        terms << {term: { parent_code: options[:parent_code] }} if options[:parent_code].present?
        terms << {term: { code: options[:code] }} if options[:code].present?

        query = {
          sort: [
            { code: { order: 'asc' } },
            { organization_id: { order: 'asc' }}
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

        response = SearchEngine.client.search index: SearchEngineConfiguration::BudgetLine.index_forecast, type: options[:type] , body: query
        response['hits']['hits'].map{ |h| h['_source'] }
      end

      def has_children?(options)
        options.symbolize_keys!
        conditions = { parent_code: options[:code], type: options[:area] }
        conditions.merge! options.slice(:organization_id,:kind,:year)

        return search(conditions)['hits'].length > 0
      end

      def top_differences(options)
        terms = [{term: { kind: options[:kind] }}, {term: { year: options[:year] }}, {term: { level: 3 }}]
        terms << {term: { organization_id: options[:organization_id] }} if options[:organization_id].present?
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

        response = SearchEngine.client.search index: SearchEngineConfiguration::BudgetLine.index_forecast, type: (options[:type] || EconomicArea.area_name), body: query

        planned_results = response['hits']['hits'].map{ |h| h['_source'] }

        response = SearchEngine.client.search index: SearchEngineConfiguration::BudgetLine.index_executed, type: (options[:type] || EconomicArea.area_name), body: query

        executed_results = response['hits']['hits'].map{ |h| h['_source'] }

        results = {}
        planned_results.each do |p|
          if e = executed_results.detect{|e| e['code'] == p['code']}
            results[p['code']] = [p['amount'], e['amount'], ((e['amount'].to_f - p['amount'].to_f)/p['amount'].to_f) * 100]
          end
        end

        return results.sort{ |b, a| a[1][2] <=> b[1][2] }[0..15], results.sort{ |a, b| a[1][2] <=> b[1][2] }[0..15]
      end

      def validate_conditions(conditions)
        if conditions.has_key?(:kind)
          raise BudgetLine::InvalidSearchConditions unless all_kinds.include?(conditions[:kind])
        end
        if conditions.has_key?(:area_name)
          raise BudgetLine::InvalidSearchConditions unless BudgetArea.all_areas_names.include?(conditions[:area_name])
        end
      end

      def any_data?(conditions = {})
        any_data = false

        indexes = (conditions[:index] ? [conditions[:index]] : [SearchEngineConfiguration::BudgetLine.index_forecast, SearchEngineConfiguration::BudgetLine.index_executed])
        areas   = (conditions[:area] ? [conditions[:area]] : BudgetArea.all_areas)

        terms = []
        terms << { term: { organization_id: conditions[:site].organization_id } } if conditions[:site]
        terms << { term: { kind: conditions[:kind] } } if conditions[:kind]
        terms << { term: { year: conditions[:year] } } if conditions[:year]

        query = {
          query: {
            filtered: {
              filter: {
                bool: {
                  must: terms
                }
              }
            }
          },
          size: 1
        }

        indexes.each do |index|
          areas.each do |area|
            response = SearchEngine.client.search(
              index: index,
              type: area.area_name,
              body: query
            )
            return true if response['hits']['hits'].any?
          end
        end

        return false
      end

    end

    included do

      private_class_method :validate_conditions

      def elastic_search_index
        SearchEngineConfiguration::BudgetLine.send(index)
      end

      def elasticsearch_as_json
        {
          organization_id: organization_id,
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

    end

  end
end
