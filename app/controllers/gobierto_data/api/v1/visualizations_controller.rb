# frozen_string_literal: true

module GobiertoData
  module Api
    module V1
      class VisualizationsController < BaseController

        # GET /api/v1/data/visualizations
        # GET /api/v1/data/visualizations.json
        # GET /api/v1/data/visualizations.csv
        def index
          respond_to do |format|
            format.json do
              render json: base_relation, links: links(:index), adapter: :json_api
            end

            format.csv do
              render_csv(csv_from_relation(base_relation, csv_options_params))
            end
          end
        end

        # GET /api/v1/data/visualizations/1
        # GET /api/v1/data/visualizations/1.json
        def show
          find_item

          render(
            json: @item,
            exclude_links: true,
            links: links(:show),
            adapter: :json_api
          )
        end

        # GET /api/v1/data/visualizations/new
        # GET /api/v1/data/visualizations/new.json
        def new
          @item = base_relation.new(name_translations: available_locales_hash)

          render(
            json: @item,
            exclude_links: true,
            with_translations: true,
            links: links(:new),
            adapter: :json_api
          )
        end

        # POST /api/v1/data/visualizations
        # POST /api/v1/data/visualizations.json
        def create
          @visualization_form = VisualizationForm.new(visualization_params.merge(site_id: current_site.id))

          if @visualization_form.save
            @item = @visualization_form.id
            render(
              json: @visualization_form.visualization,
              status: :created,
              exclude_links: true,
              with_translations: true,
              links: links(:show),
              adapter: :json_api
            )
          else
            api_errors_render(@visualization_form, adapter: :json_api)
          end
        end

        # PUT /api/v1/data/visualizations/1
        # PUT /api/v1/data/visualizations/1.json
        def update
          find_item
          @visualization_form = VisualizationForm.new(visualization_params.except(*ignored_attributes_on_update).merge(site_id: current_site.id, id: @item.id))

          if @visualization_form.save
            render(
              json: @visualization_form.visualization,
              exclude_links: true,
              with_translations: true,
              links: links,
              adapter: :json_api
            )
          else
            api_errors_render(@visualization_form, adapter: :json_api)
          end
        end

        # DELETE /api/v1/data/visualizations/1
        # DELETE /api/v1/data/visualizations/1.json
        def destroy
          find_item

          @item.destroy

          head :no_content
        end

        private

        def base_relation
          if find_dataset.present?
            @dataset.visualizations.open
          elsif find_query.present?
            @query.visualizations.open
          else
            current_site.visualizations.open
          end
        end

        def find_query
          @query = current_site.queries.find_by(id: params[:query_id])
        end

        def find_dataset
          @dataset = current_site.datasets.find_by(id: params[:dataset_id])
        end

        def visualization_params
          ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [:user_id, :query_id, :name_translations, :privacy_status, :spec])
        end

        def filter_params
          params.permit(:dataset_id, :query_id)
        end

        def find_item
          @item = base_relation.unscope(where: :privacy_status).find(params[:id])
        end

        def links(self_key = nil)
          id = @item&.id
          {
            index: gobierto_data_api_v1_visualizations_path(filter_params),
            new: new_gobierto_data_api_v1_visualization_path
          }.tap do |hash|
            if id.present?
              hash.merge!(
                show: gobierto_data_api_v1_visualization_path(id)
              )
            end

            hash[:self] = hash.delete(self_key) if self_key.present?
          end
        end

        def ignored_attributes_on_update
          [:query_id, :user_id]
        end
      end
    end
  end
end
