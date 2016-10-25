module GobiertoBudgets
  module Data
    class Lines
      def initialize(options = {})
        @what = options[:what]
        @variable = @what == 'total_budget' ? 'total_budget' : 'total_budget_per_inhabitant'
        @year = options[:year]
        @place = options[:place]
        @is_comparison = @place.is_a?(Array)
        @kind = options[:kind]
        @code = options[:code]
        @area = options[:area]
        if @code
          @variable = @what == 'total_budget' ? 'amount' : 'amount_per_inhabitant'
          areas = @area == 'economic' ? EconomicArea : FunctionalArea
          @category_name = areas.all_items[@kind][@code]
        end
      end

      def generate_json
        json = {
          kind: @kind,
          year: @year,
          title: lines_title,
          budgets: {
            @what => budget_values
          }
        }

        return json.to_json
      end

      private

      def mean_province
        filters = [ {term: { province_id: @place.province_id }} ]

        if @code
          filters.push({term: { code: @code }})
          filters.push({term: { kind: @kind }})
        end

        query = {
          query: {
            filtered: {
              filter: {
                bool: {
                  must: filters
                }
              }
            }
          },
          size: 10_000,
          "aggs": {
            "#{@variable}_per_year": {
              "terms": {
                "field": "year",
                size: 10_000
              },
              "aggs": {
                "budget_sum": {
                  "sum": {
                    "field": "#{@variable}"
                  }
                }
              }
            }
          }
        }

        response = SearchEngine.client.search index: index, type: type, body: query
        data = {}
        response['aggregations']["#{@variable}_per_year"]['buckets'].each do |r|
          data[r['key']] = (r['budget_sum']['value'].to_f / r['doc_count'].to_f).round(2)
        end

        result = []
        data.sort_by{|k,_| k }.each do |year, v|
          result.push({
            date: year.to_s,
            value: v,
            dif: data[year-1] ? delta_percentage(v, data[year-1]) : 0
          })
        end

        result.reverse
      end

      def mean_autonomy
        filters = [ {term: { autonomy_id: @place.province.autonomous_region.id }} ]

        if @code
          filters.push({term: { code: @code }})
          filters.push({term: { kind: @kind }})
        end

        query = {
          query: {
            filtered: {
              filter: {
                bool: {
                  must: filters
                }
              }
            }
          },
          size: 10_000,
          "aggs": {
            "#{@variable}_per_year": {
              "terms": {
                "field": "year",
                size: 10_000
              },
              "aggs": {
                "budget_sum": {
                  "sum": {
                    "field": "#{@variable}"
                  }
                }
              }
            }
          }
        }

        response = SearchEngine.client.search index: index, type: type, body: query
        data = {}
        response['aggregations']["#{@variable}_per_year"]['buckets'].each do |r|
          data[r['key']] = (r['budget_sum']['value'].to_f / r['doc_count'].to_f).round(2)
        end

        result = []
        data.sort_by{|k,_| k }.each do |year, v|
          result.push({
            date: year.to_s,
            value: v,
            dif: data[year-1] ? delta_percentage(v, data[year-1]) : 0
          })
        end

        result.reverse
      end

      def mean_national
        filters = []
        if @code
          filters.push({term: { code: @code }})
          filters.push({term: { kind: @kind }})
        end

        query = {
          query: {
            filtered: {
              filter: {
                bool: {
                  must: filters
                }
              }
            }
          },
          size: 10_000,
          "aggs": {
            "#{@variable}_per_year": {
              "terms": {
                "field": "year",
                size: 10_000
              },
              "aggs": {
                "budget_sum": {
                  "sum": {
                    "field": "#{@variable}"
                  }
                }
              }
            }
          }
        }

        response = SearchEngine.client.search index: index, type: type, body: query
        data = {}
        response['aggregations']["#{@variable}_per_year"]['buckets'].each do |r|
          data[r['key']] = (r['budget_sum']['value'].to_f / r['doc_count'].to_f).round(2)
        end

        result = []
        data.sort_by{|k,_| k }.each do |year, v|
          result.push({
            date: year.to_s,
            value: v,
            dif: data[year-1] ? delta_percentage(v, data[year-1]) : 0
          })
        end

        result.reverse
      end

      def place_values(place = nil)
        place = @place unless place.present?
        filters = [ {term: { ine_code: place.id }} ]

        if @code
          filters.push({term: { code: @code }})
          filters.push({term: { kind: @kind }})
        end

        query = {
          sort: [
            { year: { order: 'desc' } }
          ],
          query: {
            filtered: {
              filter: {
                bool: {
                  must: filters
                }
              }
            }
          },
          size: 10_000,
        }

        result = []
        response = SearchEngine.client.search index: index, type: type, body: query
        values = Hash[response['hits']['hits'].map{|h| h['_source']}.map{|h| [h['year'],h[@variable]] }]
        values.each do |k,v|
          dif = 0
          if old_value = values[k -1]
            dif = delta_percentage(v, old_value)
          end
          result.push({date: k.to_s, value: v, dif: dif})
        end
        result
      end

      def budget_values
        return comparison_values if @is_comparison
        [
          {
            "name":"mean_province",
            "values": mean_province
          },
          {
            "name":"mean_autonomy",
            "values": mean_autonomy
          },
          {
            "name":"mean_national",
            "values": mean_national
          },
          {
            name: @code ? @category_name : @place.name,
            "values": place_values
          }
        ]
      end

      def comparison_values
        @place.map do |place|
          {
            "name": place.name,
            "values": place_values(place)
          }
        end
      end

      def lines_title
        if @code.nil?
          @what == 'total_budget' ? "Gasto total" : "Gasto por habitante"
        else
          @what == 'total_budget' ? "#{@category_name}" : "#{@category_name} por habitante"
        end
      end

      def delta_percentage(current_year_value, old_value)
        (((current_year_value.to_f - old_value.to_f)/old_value.to_f) * 100).round(2)
      end

      def index
        SearchEngineConfiguration::TotalBudget.index_forecast
      end

      def type
        if @code.nil?
          SearchEngineConfiguration::TotalBudget.type
        else
          @area
        end
      end
    end
  end
end
