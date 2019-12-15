# frozen_string_literal: true

module GobiertoData
  module Api
    module V1
      class QueriesController < BaseController

        include ::GobiertoCommon::CustomFieldsApi

        # GET /api/v1/data/dataset/dataset-slug/q
        # GET /api/v1/data/dataset/dataset-slug/q.json
        # GET /api/v1/data/dataset/dataset-slug/q.csv
        def index
          relation = filtered_relation
          respond_to do |format|
            format.json do
              render json: relation, links: links(:index), adapter: :json_api
            end

            format.csv do
              render_csv(csv_from_relation(relation, csv_options_params))
            end
          end
        end

        # GET /api/v1/data/dataset/dataset-slug/q/1
        # GET /api/v1/data/dataset/dataset-slug/q/1.json
        # GET /api/v1/data/dataset/dataset-slug/q/1.csv
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

        # GET /api/v1/data/dataset/dataset-slug/q/1/meta
        # GET /api/v1/data/dataset/dataset-slug/q/1/meta.json
        def meta
          find_item

          render(
            json: @item,
            exclude_links: true,
            links: links(:metadata),
            adapter: :json_api
          )
        end

        # GET /api/v1/data/dataset/dataset-slug/q/new
        # GET /api/v1/data/dataset/dataset-slug/q/new.json
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

        # POST /api/v1/data/dataset/dataset-slug/q
        # POST /api/v1/data/dataset/dataset-slug/q.json
        def create
          find_dataset
          @query_form = QueryForm.new(query_params.merge(site_id: current_site.id, dataset_id: @dataset.id))

          if @query_form.save
            render(
              json: @query_form.query,
              status: :created,
              exclude_links: true,
              with_translations: true,
              links: links(:metadata, id: @query_form.query.id),
              adapter: :json_api
            )
          else
            api_errors_render(@query_form, adapter: :json_api)
          end
        end

        # PUT /api/v1/data/dataset/dataset-slug/q/1
        # PUT /api/v1/data/dataset/dataset-slug/q/1.json
        def update
          find_item
          @query_form = QueryForm.new(query_params.merge(site_id: current_site.id, dataset_id: @dataset.id, id: @item.id))

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

        # DELETE /api/v1/data/dataset/dataset-slug/q/1
        # DELETE /api/v1/data/dataset/dataset-slug/q/1.json
        def destroy
          find_item

          @item.destroy

          head :no_content
        end

        private

        def base_relation
          find_dataset
          @dataset.queries.open
        end

        def find_dataset
          @dataset = current_site.datasets.find_by!(slug: params[:dataset_slug])
        end

        def query_params
          ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [:user_id, :name_translations, :privacy_status, :sql])
        end

        def find_item
          @item = base_relation.unscope(where: :privacy_status).find(params[:id])
        end

        def links(self_key = nil, opts = {})
          id = opts[:id] || params[:id]
          {
            index: gobierto_data_api_v1_dataset_queries_path(params[:dataset_slug]),
            new: new_gobierto_data_api_v1_dataset_query_path(params[:dataset_slug])
          }.tap do |hash|
            if id.present?
              hash.merge!(
                data: gobierto_data_api_v1_dataset_query_path(params[:dataset_slug], id),
                metadata: meta_gobierto_data_api_v1_dataset_query_path(params[:dataset_slug], id)
              )
            end

            hash[:self] = hash.delete(self_key) if self_key.present?
          end
        end

      end
    end
  end
end
