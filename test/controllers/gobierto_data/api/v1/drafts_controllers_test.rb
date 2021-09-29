# frozen_string_literal: true

require "test_helper"

module GobiertoData
  module Api
    module V1
      class DraftsControllersTest < GobiertoControllerTest
        self.use_transactional_tests = false

        def site
          @site ||= sites(:madrid)
        end

        def site_with_module_disabled
          @site_with_module_disabled ||= sites(:santander)
        end

        def user
          @user ||= users(:dennis)
        end

        def admin
          @admin ||= gobierto_admin_admins(:tony)
        end

        def active_dataset
          @active_dataset ||= gobierto_data_datasets(:events_dataset)
        end

        def draft_dataset
          @draft_dataset ||= gobierto_data_datasets(:draft_dataset)
        end

        def draft_query
          @draft_query ||= gobierto_data_queries(:draft_dataset_query)
        end

        def draft_visualization
          @draft_visualization ||= gobierto_data_visualizations(:draft_dataset_visualization)
        end

        def array_data(dataset)
          [
            dataset.id.to_s,
            dataset.name,
            dataset.slug,
            dataset.table_name,
            dataset.data_updated_at.to_s,
            GobiertoCommon::CustomFieldRecord.find_by(item: dataset, custom_field: datasets_category)&.value_string
          ]
        end

        # In testing environment the draft schema doesn't exist
        def setup
          ActiveRecord::Base.connection.execute "CREATE SCHEMA IF NOT EXISTS draft"
          super
        end

        def test_query_draft_dataset_table_without_preview_token
          active_dataset.update_attribute(:visibility_level, "draft")

          with(site: site) do
            get gobierto_data_api_v1_root_path(sql: "SELECT COUNT(*) AS test_count FROM gc_events"), as: :json

            assert_response :bad_request

            response_data = response.parsed_body

            assert response_data.has_key? "errors"
            assert_match(/PG::UndefinedTable/, response_data["errors"].first["sql"])
          end
          active_dataset.update_attribute(:visibility_level, "active")
        end

        def test_query_draft_dataset_table_with_valid_preview_token
          events_count = GobiertoCalendars::Event.count
          active_dataset.update_attribute(:visibility_level, "draft")

          with(site: site) do
            get gobierto_data_api_v1_root_path(sql: "SELECT COUNT(*) AS test_count FROM gc_events", preview_token: admin.preview_token), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            assert_equal 1, response_data["data"].count
            assert_equal events_count, response_data["data"].first["test_count"]
          end
          active_dataset.update_attribute(:visibility_level, "active")
        end

        # GET /api/v1/data/datasets.json
        def test_datasets_index_without_preview_token
          with(site: site) do
            get gobierto_data_api_v1_datasets_path, as: :json

            assert_response :success

            response_data = response.parsed_body

            datasets_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            refute_includes datasets_names, draft_dataset.name
          end
        end

        # GET /api/v1/data/datasets.json
        def test_datasets_index_with_valid_preview_token
          with(site: site) do
            get gobierto_data_api_v1_datasets_path(preview_token: admin.preview_token), as: :json

            assert_response :success

            response_data = response.parsed_body

            datasets_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            assert_includes datasets_names, draft_dataset.name
          end
        end

        # GET /api/v1/data/datasets/dataset-slug.json
        def test_draft_dataset_data_without_preview_token
          with(site: site) do
            get gobierto_data_api_v1_dataset_path(draft_dataset.slug), as: :csv

            assert_response :not_found
          end
        end

        # GET /api/v1/data/datasets/dataset-slug.json
        def test_draft_dataset_data_with_valid_preview_token
          with(site: site) do
            get gobierto_data_api_v1_dataset_path(draft_dataset.slug, preview_token: admin.preview_token), as: :csv

            assert_response :success
          end
        end

        # GET /api/v1/data/datasets/dataset-slug/metadata
        def test_dataset_metadata_with_valid_preview_token
          with(site: site) do
            get meta_gobierto_data_api_v1_dataset_path(draft_dataset.slug, preview_token: admin.preview_token), as: :json

            assert_response :success
          end
        end

        def test_queries_index_without_preview_token
          with(site: site) do
            get gobierto_data_api_v1_queries_path, as: :json

            assert_response :success

            response_data = response.parsed_body

            queries_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            refute_includes queries_names, draft_query.name
          end
        end

        def test_queries_index_with_valid_preview_token
          with(site: site) do
            get gobierto_data_api_v1_queries_path(preview_token: admin.preview_token), as: :json

            assert_response :success

            response_data = response.parsed_body

            queries_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            assert_includes queries_names, draft_query.name
          end
        end

        def test_draft_query_show_without_preview_token
          with(site: site) do
            get gobierto_data_api_v1_query_path(draft_query), as: :json

            assert_response :not_found
          end
        end

        def test_draft_query_show_with_valid_preview_token
          with(site: site) do
            get gobierto_data_api_v1_query_path(draft_query, preview_token: admin.preview_token), as: :json

            assert_response :success
          end
        end

        def test_visualizations_index_without_preview_token
          with(site: site) do
            get gobierto_data_api_v1_visualizations_path, as: :json

            assert_response :success

            response_data = response.parsed_body

            visualizations_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            refute_includes visualizations_names, draft_visualization.name
          end
        end

        def test_visualizations_index_with_valid_preview_token
          with(site: site) do
            get gobierto_data_api_v1_visualizations_path(preview_token: admin.preview_token), as: :json

            assert_response :success

            response_data = response.parsed_body

            visualizations_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            assert_includes visualizations_names, draft_visualization.name
          end
        end

        def test_draft_visualization_show_without_preview_token
          with(site: site) do
            get gobierto_data_api_v1_visualization_path(draft_visualization), as: :json

            assert_response :not_found
          end
        end

        def test_draft_visualization_show_with_valid_preview_token
          with(site: site) do
            get gobierto_data_api_v1_visualization_path(draft_visualization, preview_token: admin.preview_token), as: :json

            assert_response :success
          end
        end

      end
    end
  end
end
