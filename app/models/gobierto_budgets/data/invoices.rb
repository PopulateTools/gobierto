# frozen_string_literal: true

module GobiertoBudgets
  module Data
    class Invoices
      def self.dump_csv(options)
        sort = if options[:sort_desc_by]
                 [{ options[:sort_desc_by].to_sym => { order: "desc"} }]
               elsif options[:sort_asc_by]
                 [{ options[:sort_asc_by].to_sym => { order: "asc" } }]
               end
        remove_columns = options[:except_columns].present? ? options[:except_columns].split(",") : []
        limit = options[:limit] || 100_000

        query_filters = [{ term: { location_id: options[:location_id] }}]
        if options[:date_date_range]
          # 20181028-20190128
          gte,lte = options[:date_date_range].split('-')
          query_filters.push({ range: {
            date: {
              gte: gte,
              lte: lte,
              format: 'yyyyMMdd'
            }
          }})
        end

        query = {
          sort: sort,
          query: {
            bool: {
              must: query_filters
            }
          },
          size: limit
        }

        response = SearchEngine.client.search index: GobiertoBudgetsData::GobiertoBudgets::Invoice.index, body: query
        response = response['hits']['hits'].map{ |h| h['_source'] }
        parsed_response = if remove_columns.any?
          response.map do |result|
            result.except(*remove_columns)
          end
        else
          response
        end

        data = CSV.generate do |csv|
          csv << parsed_response.first.keys if parsed_response.first.present?
          parsed_response.each do |hash|
            csv << hash.values
          end
        end

        return data
      end
    end
  end
end
