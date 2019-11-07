# frozen_string_literal: true

module GobiertoData
  module Api
    module V1
      class QueryController < ApiBaseController

        # GET /gobierto-data/api/v1
        # GET /gobierto_investments/api/v1.json
        def index
          render json: { data: nil }, adapter: :json_api
        end

      end
    end
  end
end
