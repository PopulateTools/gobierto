# frozen_string_literal: true

module GobiertoData
  module Api
    module V1
      class QueryController < BaseController

        # GET /api/v1/data?sql=SELECT%20%2A%20FROM%20table_name
        def index
          query_result = execute_query(params[:sql] || "")

          if query_result.is_a?(Hash) && query_result.has_key?(:errors)
            render json: query_result, status: :bad_request, adapter: :json_api
          else
            render json: { data: query_result }, adapter: :json_api
          end
        end

        private

        def execute_query(sql)
          GobiertoData::Connection.execute_query(current_site, Arel.sql(sql))
        end

      end
    end
  end
end
