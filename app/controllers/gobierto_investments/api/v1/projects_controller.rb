# frozen_string_literal: true

module GobiertoInvestments
  module Api
    module V1
      class ProjectsController < ApiBaseController

        include ::GobiertoCommon::CustomFieldsApi

        # GET /gobierto_investments/api/v1/projects
        # GET /gobierto_investments/api/v1/projects.json
        def index
          render json: base_relation, adapter: :json_api
        end

        # GET /gobierto_investments/api/v1/projects/1
        # GET /gobierto_investments/api/v1/projects/1.json
        def show
          find_resource

          render json: @resource, adapter: :json_api
        end

        # GET /gobierto_investments/api/v1/projects/new
        # GET /gobierto_investments/api/v1/projects/new.json
        def new
          @resource = base_relation.new

          render json: @resource, adapter: :json_api
        end

        # POST /gobierto_investments/api/v1/projects
        # POST /gobierto_investments/api/v1/projects.json
        def create
          @resource = if (external_id = params.dig(:data, :attributes, :external_id)).present?
                        base_relation.find_or_initialize_by(external_id: external_id)
                      else
                        base_relation.new
                      end
          @resource.assign_attributes(resource_params)

          if save_with_custom_fields
            render json: @resource, adapter: :json_api
          else
            api_errors_render(@resource, adapter: :json_api)
          end
        end

        # PATCH/PUT /gobierto_investments/api/v1/projects/1
        # PATCH/PUT /gobierto_investments/api/v1/projects/1
        def update
          find_resource

          @resource.assign_attributes(resource_params)

          save_with_custom_fields

          if save_with_custom_fields
            render json: @resource, adapter: :json_api
          else
            api_errors_render(@resource, adapter: :json_api)
          end
        end

        # DELETE /gobierto_investments/api/v1/projects/1
        # DELETE /gobierto_investments/api/v1/projects/1.json
        def destroy
          find_resource

          @resource.destroy

          head :no_content
        end

        private

        def find_resource
          @resource = base_relation.find(params[:id])
        end

        def base_relation
          current_site.projects
        end

        def resource_params
          params.require(:data).require(:attributes).permit(:external_id, title_translations: {})
        end

      end
    end
  end
end
