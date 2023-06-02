# frozen_string_literal: true

require "test_helper"

module GobiertoData
  module Api
    module V1

      class DatasetsDeletionControllerTest < GobiertoControllerTest
        self.use_transactional_tests = false

        attr_reader :dataset, :query, :visualization

        def auth_header
          @auth_header ||= "Bearer #{admin.primary_api_token}"
        end

        def site
          @site ||= sites(:madrid)
        end

        def admin
          @admin ||= gobierto_admin_admins(:tony)
        end

        def setup
          @dataset = gobierto_data_datasets(:dataset_to_delete)
          @query = gobierto_data_queries(:dataset_to_delete_query_to_delete)
          @visualization = gobierto_data_visualizations(:dataset_to_delete_visualization_to_delete)
          ::GobiertoData::Connection.execute_query(site, "CREATE TABLE IF NOT EXISTS #{dataset.table_name}()")
        end

        def exists_table_for_dataset?
          dataset.table_name == ::GobiertoData::Connection.execute_query(site, "SELECT to_regclass('#{dataset.table_name}')", write: true ).first["to_regclass"]
        end

        # DELETE /api/v1/data/datasets/:dataset-slug
        def test_delete_dataset_remove_also_visualizations_favourites_queries_gobierto_data_table
          with(site: site) do
            assert_equal 1, ::GobiertoData::Dataset.where(slug: dataset.slug).count
            assert_equal 1, ::GobiertoData::Query.where(dataset: dataset.id).count
            assert_equal 1, ::GobiertoData::Visualization.where(query_id: query.id).count
            assert_equal 1, ::GobiertoData::Favorite.where(favorited_type: "GobiertoData::Visualization",favorited_id: visualization.id).count
            assert_equal 1, ::GobiertoData::Favorite.where(favorited_type: "GobiertoData::Query",favorited_id: query.id).count
            assert exists_table_for_dataset?

            delete(
              gobierto_data_api_v1_dataset_path(slug: dataset.slug),
              headers: { "Authorization" => auth_header }
            )

            assert_response :no_content
            assert_equal 0, ::GobiertoData::Dataset.where(slug: dataset.slug).count
            assert_equal 0, ::GobiertoData::Query.where(dataset: dataset.id).count
            assert_equal 0, ::GobiertoData::Visualization.where(query_id: query.id).count
            assert_equal 0, ::GobiertoData::Favorite.where(favorited_type: "GobiertoData::Visualization",favorited_id: visualization.id).count
            assert_equal 0, ::GobiertoData::Favorite.where(favorited_type: "GobiertoData::Query",favorited_id: query.id).count
            refute exists_table_for_dataset?
          end
        end

        # DELETE /api/v1/data/datasets/:dataset-slug
        def test_delete_dataset_with_wrong_slug_return_404
          with(site: site) do
            delete(
              gobierto_data_api_v1_dataset_path(slug: "dataset-with-this-slug-do-not-exist"),
              headers: { "Authorization" => auth_header }
            )
            assert_response :not_found
          end
        end

      end
    end
  end
end
