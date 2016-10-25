module GobiertoBudgets
  module Api
    class IntelligenceController < ApplicationController
      def budget_lines
        place = INE::Places::Place.find params[:ine_code]
        render_404 and return if place.nil?
        years = params[:years].split(',').map(&:to_i)
        render_404 and return if years.size != 2

        hits = get_budget_lines(place: place, years: years)

        respond_to do |format|
          format.json do
            render json: hits.to_json
          end
        end
      end

      def budget_lines_means
        place = INE::Places::Place.find params[:ine_code]
        render_404 and return if place.nil?
        year = params[:year].to_i
        render_404 and return if year == 0

        hits = get_budget_lines(place: place, year: year)
        hits = merge_hits_with_province_mean(hits: hits, place: place, year: year)
        hits = merge_hits_with_autonomous_region_mean(hits: hits, place: place, year: year)
        hits = merge_hits_with_country_mean(hits: hits, year: year)

        respond_to do |format|
          format.json do
            render json: hits.to_json
          end
        end
      end

      private

      def get_budget_lines(options)
        conditions = [
          {term: { kind: GobiertoBudgets::BudgetLine::EXPENSE }},
          {term: { ine_code: options.fetch(:place).id }},
          {term: { level: 3 }},
        ]
        conditions.push({term: { year: options.fetch(:year) }}) if options.has_key?(:year)
        conditions.push({terms: { year: options.fetch(:years) }}) if options.has_key?(:years)

        query = {
          query: {
            filtered: {
              filter: {
                bool: {
                  must: conditions
                }
              }
            }
          },
          size: 10_000
        }
        response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: GobiertoBudgets::BudgetLine::FUNCTIONAL, body: query
        response['hits']['hits'].map{|g| g['_source'] }
      end

      def merge_hits_with_province_mean(options)
        query = {
          query: {
            filtered: {
              filter: {
                bool: {
                  must: [
                    {term: { kind: GobiertoBudgets::BudgetLine::EXPENSE }},
                    {term: { province_id: options.fetch(:place).province.id }},
                    {term: { level: 3 }},
                    {term: { year: options.fetch(:year) }},
                  ]
                }
              }
            }
          },
          aggs: {
            group_by_code: {
              terms: {
                field: :code,
                size: 10_000
              },
              aggs: {
                avg_amount: {
                  avg: {
                    field: :amount,
                    missing: 0
                  }
                },
                avg_amount_per_inhabitant: {
                  avg: {
                    field: :amount_per_inhabitant,
                    missing: 0
                  }
                }
              }
            }
          },
          size: 0 # Don't return hits
        }
        response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: GobiertoBudgets::BudgetLine::FUNCTIONAL, body: query
        avgs = response['aggregations']['group_by_code']['buckets']
        options.fetch(:hits).map do |hit|
          hit['avg_province'] = if v = avgs.detect{|h| h['key'] == hit['code'] }
                                  v['avg_amount']['value'].to_f.round(2)
                                else
                                  0
                                end
          hit['avg_per_inhabitant_province'] = if v = avgs.detect{|h| h['key'] == hit['code'] }
                                  v['avg_amount_per_inhabitant']['value'].to_f.round(2)
                                else
                                  0
                                end
          hit
        end
      end

      def merge_hits_with_autonomous_region_mean(options)
        query = {
          query: {
            filtered: {
              filter: {
                bool: {
                  must: [
                    {term: { kind: GobiertoBudgets::BudgetLine::EXPENSE }},
                    {term: { autonomy_id: options.fetch(:place).province.autonomous_region.id }},
                    {term: { level: 3 }},
                    {term: { year: options.fetch(:year) }},
                  ]
                }
              }
            }
          },
          aggs: {
            group_by_code: {
              terms: {
                field: :code,
                size: 10_000
              },
              aggs: {
                avg_amount: {
                  avg: {
                    field: :amount,
                    missing: 0
                  }
                },
                avg_amount_per_inhabitant: {
                  avg: {
                    field: :amount_per_inhabitant,
                    missing: 0
                  }
                }
              }
            }
          },
          size: 0 # Don't return hits
        }
        response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: GobiertoBudgets::BudgetLine::FUNCTIONAL, body: query
        avgs = response['aggregations']['group_by_code']['buckets']
        options.fetch(:hits).map do |hit|
          hit['avg_autonomy'] = if v = avgs.detect{|h| h['key'] == hit['code'] }
                                  v['avg_amount']['value'].to_f.round(2)
                                else
                                  0
                                end
          hit['avg_per_inhabitant_autonomy'] = if v = avgs.detect{|h| h['key'] == hit['code'] }
                                  v['avg_amount_per_inhabitant']['value'].to_f.round(2)
                                else
                                  0
                                end
          hit
        end
      end

      def merge_hits_with_country_mean(options)
        query = {
          query: {
            filtered: {
              filter: {
                bool: {
                  must: [
                    {term: { kind: GobiertoBudgets::BudgetLine::EXPENSE }},
                    {term: { level: 3 }},
                    {term: { year: options.fetch(:year) }},
                  ]
                }
              }
            }
          },
          aggs: {
            group_by_code: {
              terms: {
                field: :code,
                size: 10_000
              },
              aggs: {
                avg_amount: {
                  avg: {
                    field: :amount,
                    missing: 0
                  }
                },
                avg_amount_per_inhabitant: {
                  avg: {
                    field: :amount_per_inhabitant,
                    missing: 0
                  }
                }
              }
            }
          },
          size: 0 # Don't return hits
        }
        response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: GobiertoBudgets::BudgetLine::FUNCTIONAL, body: query
        avgs = response['aggregations']['group_by_code']['buckets']
        options.fetch(:hits).map do |hit|
          hit['avg_country'] = if v = avgs.detect{|h| h['key'] == hit['code'] }
                                 v['avg_amount']['value'].to_f.round(2)
                               else
                                 0
                               end
          hit['avg_per_inhabitant_country'] = if v = avgs.detect{|h| h['key'] == hit['code'] }
                                 v['avg_amount_per_inhabitant']['value'].to_f.round(2)
                               else
                                 0
                               end
          hit
        end
      end
    end
  end
end
