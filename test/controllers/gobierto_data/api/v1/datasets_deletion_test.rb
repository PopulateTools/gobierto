# frozen_string_literal: true

require "test_helper"

module GobiertoData
  module Api
    module V1
      class DatasetsDeletionControllerTest < GobiertoControllerTest
        self.use_transactional_tests = false

        def auth_header
          @auth_header ||= "Bearer #{admin.primary_api_token}"
        end

        def site
          @site ||= sites(:madrid)
        end

        def admin
          @admin ||= gobierto_admin_admins(:tony)
        end

        # DELETE /api/v1/data/datasets/:dataset-slug
        def test_delete_dataset_remove_also_visualizations_favourites_queries_gobierto_data_table
          with(site: site) do
            dataset = gobierto_data_datasets(:dataset_to_delete)
            query = gobierto_data_queries(:dataset_to_delete_query_to_delete)
            visualization = gobierto_data_visualizations(:dataset_to_delete_visualization_to_delete)
            gdata_db_name = gobierto_module_settings(:gobierto_data_settings_madrid).settings["db_config"]["read_db_config"]["database"]

            assert_equal 1, ::GobiertoData::Dataset.where(slug: dataset.slug).count
            assert_equal 1, ::GobiertoData::Query.where(dataset: dataset.id).count
            assert_equal 1, ::GobiertoData::Visualization.where(query_id: query.id).count
            assert_equal 1, ::GobiertoData::Favorite.where(favorited_type: "GobiertoData::Visualization",favorited_id: visualization.id).count
            assert_equal 1, ::GobiertoData::Favorite.where(favorited_type: "GobiertoData::Query",favorited_id: query.id).count

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

            refute ::GobiertoData::Connection.execute_query(site, "select exists (select from information_schema.tables where table_schema = '#{gdata_db_name}' and table_name = '#{dataset.table_name}')").first["exists"]
          end
        end

        def test_delete_dataset_with_wrong_slug_return_404
          with(site: site) do

            delete(
              gobierto_data_api_v1_dataset_path(slug: "this-slug-don't-exist"),
              headers: { "Authorization" => auth_header }
            )

            assert_response :not_found
          end
        end

      end
    end
  end
end
