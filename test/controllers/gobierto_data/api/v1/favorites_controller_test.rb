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

        def other_user
          @other_user ||= users(:peter)
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

        def valid_params(user)
          {
            data:
            {
              attributes:
              {
                user_id: user.id
              }
            }
          }
        end

        def test_dataset_index_with_module_disabled
          with(site: site_with_module_disabled) do
            get gobierto_data_api_v1_dataset_favorites_path(dataset.slug)

            assert_response :forbidden
          end
        end

        # GET /api/v1/data/datasets/slug/favorites.json
        def test_dataset_index_as_json
          with(site: site) do
            get gobierto_data_api_v1_dataset_favorites_path(dataset.slug), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            response_data["data"].each do |item|
              assert_equal "GobiertoData::Dataset", item["attributes"]["favorited_type"]
              assert_equal dataset.id, item["attributes"]["favorited_id"]
            end

            favorite_user_ids = response_data["data"].map { |item| item["attributes"]["user_id"] }
            favorited_dataset_ids = response_data["data"].map { |item| item["attributes"]["favorited_id"] }.uniq

            assert_equal 1, favorited_dataset_ids.count
            assert_equal dataset_favorite.favorited_id, favorited_dataset_ids.first

            assert_includes favorite_user_ids, user.id
            assert_includes favorite_user_ids, other_user.id
          end
        end

        # GET /api/v1/data/datasets/slug/favorites/user_favorited_queries?user_id=1
        def test_user_favorited_queries_on_dataset
          with(site: site) do
            get user_favorited_queries_gobierto_data_api_v1_dataset_favorites_path(dataset.slug, user_id: user.id)

            assert_response :success

            response_data = response.parsed_body

            favorited_ids = response_data["data"].map { |element| element["id"].to_i }

            assert_includes favorited_ids, query.id
            refute_includes favorited_ids, other_user_query_favorite.favorited.id
            refute_includes favorited_ids, other_dataset_query_favorite.favorited.id
          end
        end

        def test_user_favorited_visualizations_on_dataset
          with(site: site) do
            get user_favorited_visualizations_gobierto_data_api_v1_dataset_favorites_path(dataset.slug, user_id: user.id)

            assert_response :success

            response_data = response.parsed_body

            favorited_ids = response_data["data"].map { |element| element["id"].to_i }

            assert_includes favorited_ids, visualization.id
            assert_includes favorited_ids, other_visualization.id
          end
        end

        def test_user_favorited_visualizations_on_query
          with(site: site) do
            get user_favorited_visualizations_gobierto_data_api_v1_query_favorites_path(query, user_id: user.id)

            assert_response :success

            response_data = response.parsed_body

            favorited_ids = response_data["data"].map { |element| element["id"].to_i }

            assert_includes favorited_ids, visualization.id
            refute_includes favorited_ids, other_visualization.id
          end
        end

        def test_create_dataset_favorite
          with(site: site) do
            assert_difference "GobiertoData::Favorite.count", 1 do
              post gobierto_data_api_v1_dataset_favorites_path(other_dataset.slug, valid_params(other_user))

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
            post gobierto_data_api_v1_dataset_favorites_path(dataset.slug, valid_params(user))

            assert_response :unprocessable_entity
            response_data = response.parsed_body

            assert response_data.has_key? "errors"
          end
        end

        def test_delete
          id = dataset_favorite.id

          assert_difference "GobiertoData::Favorite.count", -1 do
            with(site: site) do
              delete gobierto_data_api_v1_dataset_favorite_path(dataset.slug, id)

              assert_response :no_content

              assert_nil Favorite.find_by(id: id)
            end
          end
        end

      end
    end
  end
end
