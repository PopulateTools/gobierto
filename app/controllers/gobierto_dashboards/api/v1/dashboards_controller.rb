# frozen_string_literal: true

module GobiertoDashboards
  module Api
    module V1
      class DashboardsController < BaseController
        include ::GobiertoCommon::SecuredWithAdminToken

        skip_before_action :set_admin_with_token, only: [:index, :show, :data]

        # GET /api/v1/dashboards
        # GET /api/v1/dashboards.json
        def index
          respond_to do |format|
            format.json do
              render(
                json: base_relation,
                adapter: :json_api
              )
            end
          end
        end

        # GET /api/v1/dashboards/1
        # GET /api/v1/dashboards/1.json
        def show
          find_resource

          render(
            json: @resource,
            adapter: :json_api
          )
        end

        # GET /api/v1/dashboards/1/data
        # GET /api/v1/dashboards/1/data.json
        def data
          find_resource

          render(
            json: @resource,
            serializer: ::GobiertoDashboards::DashboardDataSerializer,
            adapter: :json_api
          )
        end

        private

        def find_resource
          @resource = base_relation.find(params[:id])
        end

        def base_relation
          current_site.dashboards.active
        end
      end
    end
  end
end
