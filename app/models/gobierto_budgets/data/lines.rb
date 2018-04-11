# frozen_string_literal: true

module GobiertoBudgets
  module Data
    class Lines
      def initialize(options = {})
        @what = options[:what]
        @variable = @what == "total_budget" ? "total_budget" : "total_budget_per_inhabitant"
        @year = options[:year]
        @place = options[:place]
        @kind = options[:kind] || GobiertoBudgets::BudgetLine::EXPENSE
        @code = options[:code]
        @area = options[:area]
        @organization_name = options[:organization_name] || @place.try(:name)
        @organization_id = options[:organization_id] || @place.try(:id)
        @include_next_year = options[:include_next_year] == "true"
        if @code
          @variable = @what == "total_budget" ? "amount" : "amount_per_inhabitant"
          areas = BudgetArea.klass_for(@area)
          @category_name = areas.all_items[@kind][@code]
        end
        @comparison = options[:comparison]
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

        json.to_json
      end

      private

      def mean_filtered_by(conditions={})
        options = conditions.extract!(:options)
        force_default_last_year = options[:force_default_last_year] || true

        filters = conditions.map do |condition, _|
          { term: conditions.slice(condition) }
        end
        filters.push(term: { kind: @kind })
        filters.push(term: { code: @code }) if @code
        filters.push(missing: { field: "functional_code" })
        filters.push(missing: { field: "custom_code" })

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
                    "field": @variable.to_s
                  }
                }
              }
            }
          }
        }

        response = SearchEngine.client.search index: index, type: type, body: query
        data = {}
        response["aggregations"]["#{ @variable }_per_year"]["buckets"].each do |r|
          data[r["key"]] = (r["budget_sum"]["value"].to_f / r["doc_count"].to_f).round(2)
        end

        result = []
        data.sort_by { |k, _| k }.each do |year, v|
          next if year > GobiertoBudgets::SearchEngineConfiguration::Year.last(force_default_last_year)
          result.push(
            date: year.to_s,
            value: v,
            dif: data[year - 1] ? delta_percentage(v, data[year - 1]) : 0
          )
        end

        result.reverse
      end

      def mean_province
        @place ? mean_filtered_by(province_id: @place.province_id) : []
      end

      def mean_autonomy
        @place ? mean_filtered_by(autonomy_id: @place.province.autonomous_region.id) : []
      end

      def mean_national
        mean_filtered_by(options: { force_default_last_year: false })
      end

      def values_filtered_by(conditions)
        filters = conditions.map do |condition, _|
          { term: conditions.slice(condition) }
        end

        filters.push(missing: { field: "functional_code" })
        filters.push(missing: { field: "custom_code" })
        filters.push(term: { kind: @kind })
        filters.push(term: { code: @code }) if @code

        query = {
          sort: [
            { year: { order: "desc" } }
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
          size: 10_000
        }

        result = []
        response = SearchEngine.client.search index: index, type: type, body: query
        values = Hash[response["hits"]["hits"].map { |h| h["_source"] }.map { |h| [h["year"], h[@variable]] }]
        values.each do |k, v|
          dif = 0
          if old_value = values[k - 1]
            dif = delta_percentage(v, old_value)
          end
          if k <= GobiertoBudgets::SearchEngineConfiguration::Year.last
            result.push(date: k.to_s, value: v, dif: dif)
          elsif @include_next_year && v > 0
            result.push(date: k.to_s, value: v, dif: dif)
          end
        end
        result
      end

      def place_values(place = nil)
        place = @place unless place.present?

        place ? values_filtered_by(ine_code: place.id) : []
      end

      def organization_values
        values_filtered_by(organization_id: @organization_id)
      end

      def budget_values
        if @comparison
          place_value = [{
            name: @organization_name,
            "values": organization_values
          }]
          @comparison.map do |place_id|
            if place = INE::Places::Place.find(place_id)
              { name: place.name, values: place_values(place) }
            end
          end.compact + place_value
        else
          [
            {
              "name": "mean_province",
              "values": mean_province
            },
            {
              "name": "mean_autonomy",
              "values": mean_autonomy
            },
            {
              "name": "mean_national",
              "values": mean_national
            },
            {
              name: @organization_name,
              "values": organization_values
            }
          ]
        end
      end

      def lines_title
        if @code.nil?
          @what == "total_budget" ? I18n.t("gobierto_budgets.visualizations.total_expenses") : I18n.t("gobierto_budgets.visualizations.expenses_per_inhabitant")
        else
          @what == "total_budget" ? @category_name.to_s : I18n.t("gobierto_budgets.visualizations.category_per_inhabitant", category: @category_name)
        end
      end

      def delta_percentage(current_year_value, old_value)
        (((current_year_value.to_f - old_value.to_f) / old_value.to_f) * 100).round(2)
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
