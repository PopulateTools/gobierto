# frozen_string_literal: true

require "test_helper"

module GobiertoData
  module Api
    module V1
      class DatasetsControllerTest < GobiertoControllerTest

        def site
          @site ||= sites(:madrid)
        end

        def site_with_module_disabled
          @site_with_module_disabled ||= sites(:santander)
        end

        def user
          @user ||= users(:dennis)
        end

        def datasets_count
          @datasets_count ||= site.datasets.count
        end

        def dataset
          @dataset ||= gobierto_data_datasets(:users_dataset)
        end

        def datasets_category
          @datasets_category ||= gobierto_common_custom_fields(:madrid_data_datasets_custom_field_category)
        end

        def other_site_dataset
          @other_site_dataset ||= gobierto_data_datasets(:santander_dataset)
        end

        def array_data(dataset)
          [
            dataset.id.to_s,
            dataset.name,
            dataset.slug,
            dataset.updated_at.to_s,
            GobiertoCommon::CustomFieldRecord.find_by(item: dataset, custom_field: datasets_category)&.value_string
          ]
        end

        def test_index_with_module_disabled
          with(site: site_with_module_disabled) do
            get gobierto_data_api_v1_datasets_path

            assert_response :forbidden
          end
        end

        # GET /api/v1/data/datasets.json
        def test_index_as_json
          with(site: site) do
            get gobierto_data_api_v1_datasets_path, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            assert_equal datasets_count, response_data["data"].count
            datasets_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            assert_includes datasets_names, dataset.name
            refute_includes datasets_names, other_site_dataset.name
            assert response_data.has_key? "links"
            assert_includes response_data["links"].values, gobierto_data_api_v1_datasets_path
            assert_includes response_data["links"].values, meta_gobierto_data_api_v1_datasets_path
          end
        end

        # GET /api/v1/data/datasets.csv
        def test_index_as_csv
          with(site: site) do
            get gobierto_data_api_v1_datasets_path(format: :csv), as: :csv

            assert_response :success

            response_data = response.parsed_body
            parsed_csv = CSV.parse(response_data)

            assert_equal datasets_count + 1, parsed_csv.count
            assert_equal %w(id name slug updated_at category), parsed_csv.first
            assert_includes parsed_csv, array_data(dataset)
            refute_includes parsed_csv, array_data(other_site_dataset)
          end
        end

        # GET /api/v1/data/datasets.csv
        def test_index_csv_format_separator
          with(site: site) do
            get gobierto_data_api_v1_datasets_path(csv_separator: "semicolon", format: :csv), as: :csv

            assert_response :success

            parsed_csv_with_semicolon = CSV.parse(response.parsed_body, col_sep: ";")

            get gobierto_data_api_v1_datasets_path(format: :csv), as: :csv
            default_parsed_csv = CSV.parse(response.parsed_body)

            assert_equal parsed_csv_with_semicolon, default_parsed_csv
          end
        end

        # GET /api/v1/data/datasets/dataset-slug.json
        def test_dataset_data
          with(site: site) do
            get gobierto_data_api_v1_dataset_path(dataset.slug), as: :json

            assert_response :success
            response_data = response.parsed_body
            assert response_data.has_key? "data"
            assert_equal dataset.rails_model.count, response_data["data"].count
            assert_equal dataset.rails_model.all.map(&:id).sort, response_data["data"].map { |row| row["id"] }.sort

            assert response_data.has_key? "links"
            assert_includes response_data["links"].values, gobierto_data_api_v1_datasets_path
            assert_includes response_data["links"].values, meta_gobierto_data_api_v1_datasets_path
          end
        end

        # GET /api/v1/data/datasets/dataset-slug.csv
        def test_dataset_data_as_csv
          with(site: site) do
            get gobierto_data_api_v1_dataset_path(dataset.slug, format: :csv), as: :csv

            assert_response :success

            response_data = response.parsed_body
            parsed_csv = CSV.parse(response_data)

            assert_equal dataset.rails_model.count + 1, parsed_csv.count
          end
        end

        # GET /api/v1/data/datasets/dataset-slug/metadata
        def test_dataset_metadata
          with(site: site) do
            get meta_gobierto_data_api_v1_dataset_path(dataset.slug), as: :json

            assert_response :success
            response_data = response.parsed_body

            # data
            assert response_data.has_key? "data"
            resource_data = response_data["data"]
            assert_equal resource_data["id"], dataset.id.to_s

            # attributes
            %w(name slug updated_at data_summary data_preview).each do |attribute|
              resource_data["attributes"].has_key? attribute
            end
            assert resource_data["attributes"].has_key?(datasets_category.uid)

            # relationships
            assert resource_data.has_key? "relationships"
            resource_relationships = resource_data["relationships"]
            assert resource_relationships.has_key? "queries"
            assert resource_relationships.has_key? "visualizations"

            # links
            assert response_data.has_key? "links"
            assert_includes response_data["links"].values, gobierto_data_api_v1_datasets_path
            assert_includes response_data["links"].values, meta_gobierto_data_api_v1_datasets_path
          end
        end

      end
    end
  end
end
