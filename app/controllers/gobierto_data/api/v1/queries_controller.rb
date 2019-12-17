# frozen_string_literal: true

module GobiertoData
  module Api
    module V1
      class QueriesController < BaseController

        # GET /api/v1/data/queries
        # GET /api/v1/data/queries.json
        # GET /api/v1/data/queries.csv
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

        # GET /api/v1/data/queries/1
        # GET /api/v1/data/queries/1.json
        # GET /api/v1/data/queries/1.csv
        def show
          find_item
          query_result = @item.result
          respond_to do |format|
            format.json do
              render(
                json:
                {
                  data: query_result.delete(:result),
                  meta: query_result,
                  links: links(:data)
                },
                adapter: :json_api
              )
            end

            format.csv do
              render_csv(csv_from_query_result(query_result.fetch(:result, ""), csv_options_params))
            end
          end
        end

        # GET /api/v1/data/queries/1/meta
        # GET /api/v1/data/queries/1/meta.json
        def meta
          find_item

          render(
            json: @item,
            exclude_links: true,
            links: links(:metadata),
            adapter: :json_api
          )
        end

        # GET /api/v1/data/queries/new
        # GET /api/v1/data/queries/new.json
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

        # POST /api/v1/data/queries
        # POST /api/v1/data/queries.json
        def create
          @query_form = QueryForm.new(query_params.merge(site_id: current_site.id))

          if @query_form.save
            @item = @query_form.query
            render(
              json: @query_form.query,
              status: :created,
              exclude_links: true,
              with_translations: true,
              links: links(:metadata),
              adapter: :json_api
            )
          else
            api_errors_render(@query_form, adapter: :json_api)
          end
        end

        # PUT /api/v1/data/queries/1
        # PUT /api/v1/data/queries/1.json
        def update
          find_item
          @query_form = QueryForm.new(query_params.except(*ignored_attributes_on_update).merge(site_id: current_site.id, id: @item.id))

          if @query_form.save
            render(
              json: @query_form.query,
              exclude_links: true,
              with_translations: true,
              links: links,
              adapter: :json_api
            )
          else
            api_errors_render(@query_form, adapter: :json_api)
          end
        end

        # DELETE /api/v1/data/queries/1
        # DELETE /api/v1/data/queries/1.json
        def destroy
          find_item

          @item.destroy

          head :no_content
        end

        private

        def base_relation
          if find_dataset.present?
            @dataset.queries.open
          else
            current_site.queries.open
          end
        end

        def find_dataset
          @dataset = current_site.datasets.find_by(id: params[:dataset_id])
        end

        def query_params
          ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [:user_id, :dataset_id, :name_translations, :privacy_status, :sql])
        end

        def filter_params
          params.permit(:dataset_id)
        end

        def find_item
          @item = base_relation.unscope(where: :privacy_status).find(params[:id])
        end

        def links(self_key = nil)
          id = @item&.id
          {
            index: gobierto_data_api_v1_queries_path(filter_params),
            new: new_gobierto_data_api_v1_query_path
          }.tap do |hash|
            if id.present?
              hash.merge!(
                data: gobierto_data_api_v1_query_path(id),
                metadata: meta_gobierto_data_api_v1_query_path(id),
                visualizations: gobierto_data_api_v1_visualizations_path(query_id: id)
              )
            end

            hash[:self] = hash.delete(self_key) if self_key.present?
          end
        end

        def ignored_attributes_on_update
          [:dataset_id, :user_id]
        end

      end
    end
  end
end
