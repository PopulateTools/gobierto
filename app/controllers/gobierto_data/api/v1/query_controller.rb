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
          respond_to do |format|
            format.json do
              if stale?(stale_params)
                query_result = execute_query(params[:sql] || {}, include_stats: request.format.json?)

                render_error_or_continue(query_result) do
                  render json: { data: query_result.delete(:result), meta: query_result }, adapter: :json_api
                end
              end
            end

            format.csv do
              if stale?(stale_params)
                query_result = GobiertoData::Connection.execute_query_output_csv(current_site, Arel.sql(params[:sql] || {}), csv_options_params)

                render_error_or_continue(query_result) do
                  render_csv(query_result)
                end
              end
            end

            format.xlsx do
              if stale?(stale_params)
                query_result = execute_query(params[:sql] || {}, include_stats: false)

                render_error_or_continue(query_result) do
                  send_data(
                    GobiertoData::Connection.execute_query_output_xlsx(
                      current_site,
                      Arel.sql(params[:sql] || {}),
                      { name: "data" },
                      include_draft: valid_preview_token?
                    ).read,
                    filename: "data.xlsx"
                  )
                end
              end
            end
          end
        end

        private

        def execute_query(sql, include_stats: false)
          GobiertoData::Connection.execute_query(current_site, Arel.sql(sql), include_stats: include_stats, include_draft: valid_preview_token?)
        end

        def render_error_or_continue(query_result, &block)
          if query_result.is_a?(Hash) && query_result.has_key?(:errors)
            render json: query_result, status: :bad_request, adapter: :json_api
          else
            yield
          end
        end

        def stale_params
          {etag: GobiertoData::Cache.etag(params.values.join, current_site), last_modified: GobiertoData::Cache.last_modified(current_site)}
        end
      end
    end
  end
end
