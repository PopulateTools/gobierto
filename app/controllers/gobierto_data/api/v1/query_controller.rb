# frozen_string_literal: true

module GobiertoData
  module Api
    module V1
      class QueryController < ApiBaseController

        # GET /api/v1/data?sql=SELECT%20%2A%20FROM%20table_name
        def index
          render json: { data: execute_query(params[:sql] || "") }, adapter: :json_api
        end

        private

        def execute_query(sql)
          GobiertoData::Connection.execute_query(current_site, Arel.sql(sql))
        end

      end
    end
  end
end
