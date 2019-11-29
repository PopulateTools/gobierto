# frozen_string_literal: true

module GobiertoData
  module Api
    module V1
      class DatasetsController < BaseController

        include ::GobiertoCommon::CustomFieldsApi

        # GET /api/v1/data/datasets
        # GET /api/v1/data/datasets.json
        # GET /api/v1/data/datasets.csv
        def index
          respond_to do |format|
            format.json do
              render json: base_relation, links: { self: gobierto_data_api_v1_datasets_path }, adapter: :json_api
            end

            format.csv do
              render_csv(csv_from_relation(base_relation, csv_options_params))
            end
          end
        end

        # GET /api/v1/data/datasets/dataset-slug
        # GET /api/v1/data/datasets/dataset-slug.json
        # GET /api/v1/data/datasets/dataset-slug.csv
        def show
          find_item
          relation = @item.rails_model.all
          query_result = execute_query relation
          respond_to do |format|
            format.json do
              render(
                json:
                {
                  data: query_result.delete(:result),
                  meta: query_result,
                  links:
                  {
                    self: gobierto_data_api_v1_dataset_path(params[:slug], format: :json),
                    metadata: meta_gobierto_data_api_v1_dataset_path(params[:slug])
                  }
                },
                adapter: :json_api
              )
            end

            format.csv do
              render_csv(csv_from_query_result(query_result.fetch(:result, ""), csv_options_params))
            end
          end
        end

        # GET /api/v1/data/datasets/dataset-slug/metadata
        # GET /api/v1/data/datasets/dataset-slug/metadata.json
        def dataset_meta
          find_item

          render(
            json: @item,
            serializer: ::GobiertoData::DatasetMetaSerializer
          )
        end

        private

        def base_relation
          current_site.datasets
        end

        def find_item
          @item = base_relation.find_by!(slug: params[:slug])
        end

        def execute_query(relation)
          GobiertoData::Connection.execute_query(current_site, relation.to_sql)
        end

      end
    end
  end
end
