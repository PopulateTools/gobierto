# frozen_string_literal: true

module GobiertoData
  module Api
    module V1
      class QueryController < BaseController

        # GET /api/v1/data?sql=SELECT%20%2A%20FROM%20table_name
        # GET /api/v1/data.json?sql=SELECT%20%2A%20FROM%20table_name
        # GET /api/v1/data.csv?sql=SELECT%20%2A%20FROM%20table_name
        # GET /api/v1/data.xlsx?sql=SELECT%20%2A%20FROM%20table_name
        def index
          query_result = execute_query(params[:sql] || {}, include_stats: request.format.json?)

          if query_result.is_a?(Hash) && query_result.has_key?(:errors)
            render json: query_result, status: :bad_request, adapter: :json_api
          else
            respond_to do |format|
              format.json do
                render json: { data: query_result.delete(:result), meta: query_result }, adapter: :json_api
              end

              format.csv do
                render_csv(csv_from_query_result(query_result, csv_options_params))
              end

              format.xlsx do
                send_data xlsx_from_query_result(query_result).read, filename: "data.xlsx"
              end
            end
          end
        end

        def stream_data
          total_rows = query_rows_count(params[:sql])

          if total_rows.is_a?(Hash)
            render json: total_rows.slice(:errors), status: :bad_request, adapter: :json_api
          else
            set_streaming_headers
            response.status = 200

            respond_to do |format|
              format.json do
                self.response_body = json_stream_data(params[:sql], total_rows)
              end

              format.csv do
                set_csv_headers
                self.response_body = csv_stream_data(params[:sql], csv_options_params)
              end
            end
          end
        end

        def execute_query(sql, include_stats: false)
          GobiertoData::Connection.execute_query(current_site, Arel.sql(sql), include_stats: include_stats, include_draft: valid_preview_token?)
        end

      end
    end
  end
end
