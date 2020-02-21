# frozen_string_literal: true

module GobiertoData
  module Api
    module V1
      class LiveStreamQueryController < BaseController
        include ActionController::Live

        # GET /api/v1/live_stream_data?sql=SELECT%20%2A%20FROM%20table_name
        # GET /api/v1/live_stream_data.json?sql=SELECT%20%2A%20FROM%20table_name
        # GET /api/v1/live_stream_data.csv?sql=SELECT%20%2A%20FROM%20table_name
        def index
          total_rows = query_rows_count(params[:sql])

          if total_rows.is_a?(Hash)
            render json: total_rows.slice(:errors), status: :bad_request, adapter: :json_api
          else
            set_streaming_headers
            response.status = 200

            respond_to do |format|
              format.json do
                json_live_stream_data(params[:sql], total_rows)
              end

              format.csv do
                set_csv_headers
                csv_live_stream_data(params[:sql], csv_options_params)
              end
            end
          end
        end

        private

        def json_live_stream_data(sql, total_rows)
          row_num = 0
          response.stream.write "{\"data\":["
          execute_stream_query(sql) do |execution|
            time = Benchmark.measure do
              execution.stream_each do |row|
                row_num += 1
                response.stream.write row.to_json
                response.stream.write "," unless row_num == total_rows
              end
            end
            response.stream.write "],\"meta\":{\"duration\":#{time.real},\"rows\":#{total_rows},\"status\":\"#{execution.cmd_status}\"}}"
          end
        ensure
          response.stream.close
        end

        def csv_live_stream_data(sql, options = {})
          execute_stream_query(sql) do |execution|
            response.stream.write CSV.generate_line(execution.fields, **options)
            execution.stream_each_row do |row|
              response.stream.write CSV.generate_line(row, **options)
            end
          end
        ensure
          response.stream.close
        end
      end
    end
  end
end
