# frozen_string_literal: true

module GobiertoCommon
  module Api
    module V1
      class SearchController < ApiBaseController

        # GET /api/v1/search?query=term&filters[searchable_type][]=GobiertoPeople::Person&page[number]=1&page[size]=5
        def query
          search_result = current_site.multisearch(params[:query]).where(filters_params).page(page_params[:number]).per(page_params[:size])

          render(
            json: search_result,
            each_serializer: GobiertoCommon::SearchDocumentSerializer,
            adapter: :json_api,
            meta: {
              hits_count: search_result.total_count,
              page: search_result.current_page,
              per_page: search_result.limit_value
            }
          )
        end

        private

        def filters_params
          @filters_params ||= params.fetch(:filters, {}).permit(searchable_type: [])
        end

        def page_params
          @page_params ||= params.fetch(:page, {}).permit(:number, :size)
        end
      end
    end
  end
end
