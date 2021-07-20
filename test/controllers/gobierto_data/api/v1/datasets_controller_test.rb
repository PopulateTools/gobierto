# frozen_string_literal: true

require "test_helper"
require "support/concerns/api/api_protection_test"

module GobiertoData
  module Api
    module V1
      class DatasetsControllerTest < GobiertoControllerTest
        include ::Api::ApiProtectionTest

        def setup
          super

          setup_api_protection_test(
            path: gobierto_data_api_v1_datasets_path,
            site: site,
            admin: admin,
            token_with_domain: gobierto_admin_api_tokens(:tony_domain),
            token_with_other_domain: gobierto_admin_api_tokens(:tony_other_domain)
          )
        end

        def site
          @site ||= sites(:madrid)
        end

        def admin
          @admin ||= gobierto_admin_admins(:tony)
        end

        def site_with_module_disabled
          @site_with_module_disabled ||= sites(:santander)
        end

        def user
          @user ||= users(:dennis)
        end

        def active_datasets_count
          @active_datasets_count ||= site.datasets.active.count
        end

        def dataset
          @dataset ||= gobierto_data_datasets(:users_dataset)
        end
        alias big_dataset dataset

        def other_dataset
          @other_dataset ||= gobierto_data_datasets(:events_dataset)
        end
        alias small_dataset other_dataset

        def no_size_dataset
          @no_size_dataset ||= gobierto_data_datasets(:no_size_dataset)
        end

        def to_delete_dataset
          @to_delete_dataset ||= gobierto_data_datasets(:dataset_to_delete)
        end

        def datasets_category
          @datasets_category ||= gobierto_common_custom_fields(:madrid_data_datasets_custom_field_category)
        end

        def datasets_md_without_translations
          @datasets_md_without_translations ||= gobierto_common_custom_fields(:madrid_data_datasets_custom_field_md_without_translations)
        end

        def datasets_md_with_translations
          @datasets_md_with_translations ||= gobierto_common_custom_fields(:madrid_data_datasets_custom_field_md_with_translations)
        end

        def other_site_dataset
          @other_site_dataset ||= gobierto_data_datasets(:santander_dataset)
        end

        def attachment
          @attachment ||= gobierto_attachments_attachments(:txt_pdf_attachment)
        end

        def api_settings
          @api_settings ||= gobierto_module_settings(:gobierto_data_settings_madrid).api_settings
        end

        def delete_cached_files
          FileUtils.rm_rf(Rails.root.join(GobiertoData::Cache::BASE_PATH))
        end

        def array_data(dataset)
          [
            dataset.id.to_s,
            dataset.name,
            dataset.slug,
            dataset.table_name,
            dataset.data_updated_at.to_s,
            dataset.rails_model&.columns_hash&.transform_values(&:type)&.to_s,
            GobiertoCommon::CustomFieldRecord.find_by(item: dataset, custom_field: datasets_category)&.value_string,
            GobiertoCommon::CustomFieldRecord.find_by(item: dataset, custom_field: datasets_md_without_translations)&.value_string,
            GobiertoCommon::CustomFieldRecord.find_by(item: dataset, custom_field: datasets_md_with_translations)&.value_string
          ]
        end

        def test_index_with_module_disabled
          with(site: site_with_module_disabled) do
            get gobierto_data_api_v1_datasets_path

            assert_response :forbidden
          end
        end

        def token_with_domain
          @token_with_domain ||= gobierto_admin_api_tokens(:tony_domain)
        end

        def token_with_other_domain
          @token_with_other_domain ||= gobierto_admin_api_tokens(:tony_other_domain)
        end

        # GET /api/v1/data/datasets.json
        def test_index_as_json
          with(site: site) do
            get gobierto_data_api_v1_datasets_path, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            assert_equal active_datasets_count, response_data["data"].count
            datasets_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            assert_includes datasets_names, dataset.name
            refute_includes datasets_names, other_site_dataset.name
            first_item_keys = response_data["data"].first["attributes"].keys
            %w(name slug data_updated_at columns).each do |attribute|
              assert_includes first_item_keys, attribute
            end
            assert response_data.has_key? "links"
            assert_includes response_data["links"].values, gobierto_data_api_v1_datasets_path
            assert_includes response_data["links"].values, meta_gobierto_data_api_v1_datasets_path
          end
        end

        # GET /api/v1/data/datasets.json
        def test_index_datasets_order
          with(site: site) do
            dataset.update_attribute(:data_updated_at, 1.minute.ago)
            other_dataset.update_attribute(:data_updated_at, 1.hour.ago)

            get gobierto_data_api_v1_datasets_path, as: :json
            response_data = response.parsed_body
            datasets_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            assert_equal [dataset.name, to_delete_dataset.name, no_size_dataset.name, other_dataset.name], datasets_names

            other_dataset.update_attribute(:data_updated_at, 1.second.ago)

            get gobierto_data_api_v1_datasets_path, as: :json
            response_data = response.parsed_body
            datasets_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            assert_equal [other_dataset.name, dataset.name, to_delete_dataset.name, no_size_dataset.name], datasets_names
          end
        end

        # GET /api/v1/data/datasets.csv
        def test_index_as_csv
          with(site: site) do
            get gobierto_data_api_v1_datasets_path(format: :csv), as: :csv

            assert_response :success

            response_data = response.parsed_body
            parsed_csv = CSV.parse(response_data).map { |row| row.map(&:to_s) }

            assert_equal active_datasets_count + 1, parsed_csv.count
            assert_equal %w(id name slug table_name data_updated_at columns category md-without-translations md-with-translations), parsed_csv.first
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

        # GET /api/v1/data/datasets.xlsx
        def test_index_xlsx_format
          with(site: site) do
            get gobierto_data_api_v1_datasets_path(format: :xlsx), as: :xlsx

            assert_response :success

            parsed_xlsx = RubyXL::Parser.parse_buffer response.parsed_body

            assert_equal 1, parsed_xlsx.worksheets.count
            sheet = parsed_xlsx.worksheets.first
            assert_nil sheet[active_datasets_count + 1]
            assert_equal %w(id name slug table_name data_updated_at columns category md-without-translations md-with-translations), sheet[0].cells.map(&:value)
            values = (1..active_datasets_count).map do |row_number|
              sheet[row_number].cells.map { |cell| cell.value.to_s }
            end
            assert_includes values, array_data(dataset)
            refute_includes values, array_data(other_site_dataset)
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
            attributes_keys = resource_data["attributes"].keys
            %w(name slug data_updated_at data_summary columns formats size default_limit).each do |attribute|
              assert_includes attributes_keys, attribute
            end
            assert resource_data["attributes"].has_key?(datasets_category.uid)

            # relationships
            assert resource_data.has_key? "relationships"
            resource_relationships = resource_data["relationships"]
            assert resource_relationships.has_key? "queries"
            assert resource_relationships.has_key? "visualizations"
            assert resource_relationships.has_key? "attachments"

            # included
            assert response_data.has_key? "included"
            included = response_data["included"]

            # datasets
            attachments_names = included.select { |item| item["type"] = "gobierto_attachments-attachments" }.map { |attachment| attachment.dig("attributes", "name") }
            assert_includes attachments_names, attachment.name

            # links
            assert response_data.has_key? "links"
            assert_includes response_data["links"].values, gobierto_data_api_v1_datasets_path
            assert_includes response_data["links"].values, meta_gobierto_data_api_v1_datasets_path
          end
        end

        # GET /api/v1/data/datasets/dataset-slug/metadata
        def test_size_and_default_limit_meta_attributes
          with(site: site) do
            get meta_gobierto_data_api_v1_dataset_path(big_dataset.slug), as: :json
            big_dataset_response_data = response.parsed_body
            get meta_gobierto_data_api_v1_dataset_path(small_dataset.slug), as: :json
            small_dataset_response_data = response.parsed_body
            get meta_gobierto_data_api_v1_dataset_path(no_size_dataset.slug), as: :json
            no_size_dataset_response_data = response.parsed_body

            assert_equal 50, big_dataset_response_data["data"]["attributes"]["default_limit"]
            assert_equal 50, no_size_dataset_response_data["data"]["attributes"]["default_limit"]
            assert_nil small_dataset_response_data["data"]["attributes"]["default_limit"]

            assert_equal 15, big_dataset_response_data["data"]["attributes"]["size"]["csv"]
            assert_equal 3, small_dataset_response_data["data"]["attributes"]["size"]["csv"]
          end
        end

        # GET /api/v1/data/datasets/dataset-slug/download.csv
        def test_dataset_download_as_csv
          with(site: site) do
            get download_gobierto_data_api_v1_dataset_path(dataset.slug, format: :csv), as: :csv

            assert_response :success
            response_data = response.parsed_body
            parsed_csv = CSV.parse(response_data)

            assert_equal dataset.rails_model.count + 1, parsed_csv.count

            assert File.exist? Rails.root.join("#{GobiertoData::Cache::BASE_PATH}/datasets/#{dataset.id}.csv")
            delete_cached_files
          end
        end

        def test_index_when_md_custom_field_changes_translations_availability
          datasets_md_with_translations.update_attribute(:field_type, GobiertoCommon::CustomField.field_types[:paragraph])
          datasets_md_without_translations.update_attribute(:field_type, GobiertoCommon::CustomField.field_types[:localized_paragraph])

          with(site: site) do
            get gobierto_data_api_v1_datasets_path(format: :csv), as: :csv

            assert_response :success

            response_data = response.parsed_body
            parsed_csv = CSV.parse(response_data).map { |row| row.map(&:to_s) }

            assert_equal active_datasets_count + 1, parsed_csv.count
            assert_equal %w(id name slug table_name data_updated_at columns category md-without-translations md-with-translations), parsed_csv.first
            assert_includes parsed_csv, array_data(dataset)
            refute_includes parsed_csv, array_data(other_site_dataset)
          end
        end

      end
    end
  end
end
