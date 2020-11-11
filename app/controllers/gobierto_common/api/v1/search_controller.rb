# frozen_string_literal: true

module GobiertoCommon
  module Api
    module V1
      class SearchController < ApiBaseController

        # GET /api/v1/search?query=term&filters[searchable_type][]=GobiertoPeople::Person
        def query
          search_result = current_site.multisearch(params[:query]).where(filters_params).limit(25)

          render(
            json: search_result,
            each_serializer: GobiertoCommon::SearchDocumentSerializer,
            adapter: :json_api,
          )
        end

        private

        def filters_params
          @filters_params ||= params.fetch(:filters, {}).permit(searchable_type: [])
        end
      end
    end
  end
end
