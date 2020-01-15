# frozen_string_literal: true

require "test_helper"

module GobiertoData
  module Api
    module V1
      class FavoritessControllerTest < GobiertoControllerTest

        def site
          @site ||= sites(:madrid)
        end

        def site_with_module_disabled
          @site_with_module_disabled ||= sites(:santander)
        end

        def user
          @user ||= users(:dennis)
        end

        def user_token
          @user_token ||= user_api_tokens(:dennis_primary_api_token)
        end

        def other_user
          @other_user ||= users(:janet)
        end

        def other_user_favorited_query
          @other_user_favorited_query ||= gobierto_data_queries(:census_verified_users_query)
        end

        def other_user_favorited_visualization
          @other_user_favorited_visualization ||= gobierto_data_visualizations(:events_count_closed_visualization)
        end

        def other_user_token
          @other_user_token ||= user_api_tokens(:janet_primary_api_token)
        end

        def dataset_favorite
          @dataset_favorite ||= gobierto_data_favorites(:dennis_users_dataset_favorite)
        end

        def other_user_query_favorite
          @other_user_query_favorite ||= gobierto_data_favorites(:reed_census_verified_users_query_favorite)
        end

        def other_dataset_query_favorite
          @other_dataset_query_favorite ||= gobierto_data_favorites(:dennis_events_count_query_favorite)
        end

        def dataset
          @dataset ||= gobierto_data_datasets(:users_dataset)
        end

        def other_dataset
          @other_dataset ||= gobierto_data_datasets(:events_dataset)
        end

        def query
          @query ||= gobierto_data_queries(:users_count_query)
        end

        def visualization
          @visualization ||= gobierto_data_visualizations(:users_count_visualization)
        end

        def other_visualization
          @other_visualization ||= gobierto_data_visualizations(:census_verified_users_visualization)
        end

        def test_dataset_index_with_module_disabled
          with(site: site_with_module_disabled) do
            get gobierto_data_api_v1_dataset_favorites_path(dataset.slug)

            assert_response :forbidden
          end
        end

        # GET /api/v1/data/datasets/slug/favorites.json
        def test_dataset_index_without_token
          with(site: site) do
            get gobierto_data_api_v1_dataset_favorites_path(dataset.slug), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert_empty response_data["data"]
          end
        end

        # GET /api/v1/data/datasets/slug/favorites.json
        def test_dataset_index_as_json_with_token
          with(site: site) do
            get gobierto_data_api_v1_dataset_favorites_path(dataset.slug), headers: { Authorization: user_token.token }, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            favorited_resources = response_data["data"].map do |item|
              item["attributes"]["favorited_type"].constantize.find(item["attributes"]["favorited_id"])
            end
            favorited_resources.each do |resource|
              assert resource.favorited_by_user? user
              assert_equal dataset, resource.try(:dataset) || resource
            end

            refute_includes favorited_resources, other_dataset_query_favorite
            assert_includes favorited_resources, dataset

            assert response_data.has_key? "meta"
            assert response_data["meta"]["self_favorited"]
          end
        end

        # GET /api/v1/data/datasets/slug/favorites.json
        def test_dataset_index_filtered_by_user_id
          with(site: site) do
            get gobierto_data_api_v1_dataset_favorites_path(dataset.slug, filter: { user_id: user.id }), headers: { Authorization: other_user_token.token }, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            favorited_resources = response_data["data"].map do |item|
              item["attributes"]["favorited_type"].constantize.find(item["attributes"]["favorited_id"])
            end
            favorited_resources.each do |resource|
              assert resource.favorited_by_user? user
              assert_equal dataset, resource.try(:dataset) || resource
            end

            refute_includes favorited_resources, other_dataset_query_favorite
            assert_includes favorited_resources, dataset

            assert response_data.has_key? "meta"
            assert response_data["meta"]["self_favorited"]
          end
        end

        def test_query_index_with_token
          with(site: site) do
            get gobierto_data_api_v1_query_favorites_path(other_user_favorited_query), headers: { Authorization: other_user_token.token }, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            favorited_resources = response_data["data"].map do |item|
              item["attributes"]["favorited_type"].constantize.find(item["attributes"]["favorited_id"])
            end
            favorited_resources.each do |resource|
              assert resource.favorited_by_user? other_user
              assert_equal other_user_favorited_query, resource.try(:query) || resource
            end

            refute_includes favorited_resources, other_dataset_query_favorite
            assert_includes favorited_resources, other_user_favorited_query

            assert response_data.has_key? "meta"
            assert response_data["meta"]["self_favorited"]
            refute response_data["meta"]["dataset_favorited"]
          end
        end

        def test_visualization_index_with_token
          with(site: site) do
            get gobierto_data_api_v1_visualization_favorites_path(other_user_favorited_visualization), headers: { Authorization: other_user_token.token }, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            favorited_resources = response_data["data"].map do |item|
              item["attributes"]["favorited_type"].constantize.find(item["attributes"]["favorited_id"])
            end
            favorited_resources.each do |resource|
              assert resource.favorited_by_user? other_user
              assert_equal other_user_favorited_visualization, resource
            end

            refute_includes favorited_resources, visualization
            assert_includes favorited_resources, other_user_favorited_visualization

            assert response_data.has_key? "meta"
            assert response_data["meta"]["self_favorited"]
            refute response_data["meta"]["query_favorited"]
            refute response_data["meta"]["dataset_favorited"]
          end
        end

        def test_create_dataset_favorite_without_token
          with(site: site) do
            assert_no_difference "GobiertoData::Favorite.count", 1 do
              post gobierto_data_api_v1_dataset_favorite_path(other_dataset.slug)

              assert_response :unauthorized
            end
          end
        end

        def test_create_dataset_favorite_with_invalid_token
          with(site: site) do
            assert_no_difference "GobiertoData::Favorite.count", 1 do
              post gobierto_data_api_v1_dataset_favorite_path(other_dataset.slug), headers: { Authorization: "wadus" }

              assert_response :unauthorized
            end
          end
        end

        def test_create_dataset_favorite
          with(site: site) do
            assert_difference "GobiertoData::Favorite.count", 1 do
              post gobierto_data_api_v1_dataset_favorite_path(other_dataset.slug), headers: { Authorization: other_user_token.token }

              assert_response :created
              response_data = response.parsed_body

              new_favorite = Favorite.last

              assert response_data.has_key? "data"
              resource_data = response_data["data"]

              assert_equal resource_data["id"], new_favorite.id.to_s
              assert_equal resource_data["attributes"]["user_id"], other_user.id
              assert_equal resource_data["attributes"]["favorited_id"], other_dataset.id
              assert_equal resource_data["attributes"]["favorited_type"], "GobiertoData::Dataset"
            end
          end
        end

        def test_create_dataset_favorite_already_favorited
          with(site: site) do
            post gobierto_data_api_v1_dataset_favorite_path(dataset.slug), headers: { Authorization: user_token.token }

            assert_response :unprocessable_entity
            response_data = response.parsed_body

            assert response_data.has_key? "errors"
          end
        end

        def test_delete_without_token
          assert_no_difference "GobiertoData::Favorite.count" do
            with(site: site) do
              delete gobierto_data_api_v1_dataset_favorite_path(dataset.slug)

              assert_response :unauthorized
            end
          end
        end

        def test_delete_with_invalid_token
          assert_no_difference "GobiertoData::Favorite.count" do
            with(site: site) do
              delete gobierto_data_api_v1_dataset_favorite_path(dataset.slug), headers: { Authorization: "wadus" }

              assert_response :unauthorized
            end
          end
        end

        def test_delete_with_other_user_token
          assert_no_difference "GobiertoData::Favorite.count" do
            with(site: site) do
              delete gobierto_data_api_v1_dataset_favorite_path(dataset.slug), headers: { Authorization: other_user_token.token }

              assert_response :unauthorized
            end
          end
        end

        def test_delete
          id = dataset_favorite.id

          assert_difference "GobiertoData::Favorite.count", -1 do
            with(site: site) do
              delete gobierto_data_api_v1_dataset_favorite_path(dataset.slug), headers: { Authorization: user_token.token }

              assert_response :no_content

              assert_nil Favorite.find_by(id: id)
            end
          end
        end

      end
    end
  end
end
