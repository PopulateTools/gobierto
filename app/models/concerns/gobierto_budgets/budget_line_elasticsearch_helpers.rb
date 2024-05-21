module GobiertoBudgets
  module BudgetLineElasticsearchHelpers
    extend ActiveSupport::Concern

    class_methods do

      SORT_ATTRIBUTE = 'code'
      SORT_ORDER     = 'asc'

      def first(params = {})
        conditions = params[:where]
        validate_conditions(conditions)

        area = BudgetArea.klass_for(conditions[:area_name])

        terms = [
          {term: { kind: conditions[:kind] }},
          {term: { year: conditions[:year] }},
          {term: { code: conditions[:code] }},
          {term: { organization_id: conditions[:site].organization_id }},
          {term: { type: area.area_name }},
        ]

        must_not_terms = []
        must_not_terms.push({exists: { field: 'functional_code'}})
        must_not_terms.push({exists: { field: 'custom_code'}})

        query = {
          sort: [
            { SORT_ATTRIBUTE => { order: SORT_ORDER } }
          ],
          query: {
            bool: {
              must: terms
            }.merge(must_not_terms.present? ? { must_not: must_not_terms } : {})
          },
          size: 10
        }

        response = SearchEngine.client.search(
          index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
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
          {term: { organization_id: conditions[:site].organization_id }},
          {term: { type: EconomicArea.area_name }}
        ]

        query = {
          sort: [
            { SORT_ATTRIBUTE => { order: SORT_ORDER } }
          ],
          query: {
            bool: {
              must: terms
            }
          },
          aggs: {
            total_budget: { sum: { field: 'amount' } },
            total_budget_per_inhabitant: { sum: { field: 'amount_per_inhabitant' } },
          },
          size: 10_000
        }

        response = SearchEngine.client.search index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, body: query

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

        area = BudgetArea.klass_for(conditions[:area_name])

        terms = [
          {term: { kind: conditions[:kind] }},
          {term: { organization_id: conditions[:site].organization_id }},
          {term: { type: area.area_name }}
        ]
        must_not_terms = []

        terms.push({term: { year: conditions[:year] }}) if conditions[:year]
        terms.push({term: { code: conditions[:code] }}) if conditions[:code]
        terms.push({term: { level: conditions[:level] }}) if conditions[:level]
        terms.push({term: { parent_code: conditions[:parent_code] }}) if conditions[:parent_code]
        if conditions.has_key?(:functional_code)
          if conditions[:area_name] == FunctionalArea.area_name
            conditions[:area_name] = EconomicArea.area_name
            if conditions[:functional_code].present?
              terms.push(term: { functional_code: conditions[:functional_code] })
            else
              terms.push(exists: { field: "functional_code" })
            end
          else
            conditions[:area_name] = FunctionalArea.area_name
            return functional_codes_for_economic_budget_line(where: conditions)
          end
        elsif conditions.has_key?(:custom_code)
          if conditions[:area_name] == CustomArea.area_name
            conditions[:area_name] = EconomicArea.area_name
            if conditions[:custom_code].present?
              terms.push(term: { custom_code: conditions[:custom_code] })
            else
              terms.push(exists: { field: "custom_code" })
            end
          end
        else
          must_not_terms.push({exists: { field: 'functional_code'}})
          must_not_terms.push({exists: { field: 'custom_code'}})
        end

        query = {
          sort: [
            { SORT_ATTRIBUTE => { order: SORT_ORDER } }
          ],
          query: {
            bool: {
              must: terms
            }.merge(must_not_terms.present? ? { must_not: must_not_terms } : {})
          },
          aggs: {
            total_budget: { sum: { field: 'amount' } },
            total_budget_per_inhabitant: { sum: { field: 'amount_per_inhabitant' } },
          },
          size: 10_000
        }

        default_index = GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast

        index = if updated_forecast
                  GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast_updated
                else
                  conditions[:index] || default_index
                end

        response = SearchEngine.client.search(index: index, body: query)

        if updated_forecast && response["hits"]["hits"].empty?
          response = SearchEngine.client.search(index: default_index, body: query)
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
        terms << {term: { type: (options[:type] || EconomicArea.area_name) }}

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
            bool: {
              must: terms
            }
          },
          aggs: {
            total_budget: { sum: { field: 'amount' } },
            total_budget_per_inhabitant: { sum: { field: 'amount_per_inhabitant' } },
          },
          size: 10_000
        }

        default_index = GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast
        index = updated_forecast ? GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast_updated : default_index

        response = SearchEngine.client.search(index: index, body: query)

        if updated_forecast && response["hits"]["hits"].empty?
          response = SearchEngine.client.search(index: default_index, body: query)
        end

        return {
          'hits' => response['hits']['hits'].map{ |h| h['_source'] },
          'aggregations' => response['aggregations']
        }
      end

      def find(options)
        return self.search(options)['hits'].detect{|h| h['code'] == options[:code] }
      end

      def get_source(params = {})
        SearchEngine.client.get_source(index: params[:index], id: params[:id])
      end

      def find_details(params = {})
        common_params = { id: params[:id] }

        budget_line = Hashie::Mash.new(
          id: params[:id],
          area: params[:type],
          forecast: {},
          execution: {}
        )

        forecast_info = SearchEngine.client.get_source(common_params.merge(
          index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast
        ))

        raise BudgetLine::RecordNotFound unless forecast_info

        forecast_updated_info = SearchEngine.client.get_source(common_params.merge(
          index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast_updated
        ))
        execution_info = SearchEngine.client.get_source(common_params.merge(
          index: GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed
        ))

        budget_line.forecast.original_amount = forecast_info["amount"] if forecast_info
        budget_line.forecast.updated_amount = forecast_updated_info["amount"] if forecast_updated_info
        budget_line.execution.amount = execution_info["amount"] if execution_info
        budget_line
      end

      def has_children?(options)
        options.symbolize_keys!
        conditions = { parent_code: options[:code], type: options[:area] }
        conditions.merge! options.slice(:organization_id,:kind,:year)

        return search(conditions)['hits'].length > 0
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

        indexes = (conditions[:index] ? [conditions[:index]] : [GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed])
        areas   = (conditions[:area] ? [conditions[:area]] : BudgetArea.all_areas)

        base_terms = []
        base_terms << { term: { organization_id: conditions[:site].organization_id } } if conditions[:site]
        base_terms << { term: { kind: conditions[:kind] } } if conditions[:kind]
        base_terms << { term: { year: conditions[:year] } } if conditions[:year]

        indexes.each do |index|
          areas.each do |area|
            query = {
              query: {
                bool: {
                  must: base_terms.append({ term: { type: area.area_name } })
                }
              },
              size: 1
            }

            response = SearchEngine.client.search(
              index: index,
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
        GobiertoBudgetsData::GobiertoBudgets::BudgetLine.send(index)
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
