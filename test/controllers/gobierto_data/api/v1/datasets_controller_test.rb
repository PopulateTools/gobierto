# frozen_string_literal: true

require "test_helper"

module GobiertoData
  module Api
    module V1
      class DatasetsControllerTest < GobiertoControllerTest

        def site
          @site ||= sites(:madrid)
        end

        def admin_auth_header
          @admin_auth_header ||= "Bearer #{admin.primary_api_token}"
        end

        def basic_auth_header
          @basic_auth_header ||= "Basic #{Base64.encode64("username:password")}"
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

        def other_dataset
          @other_dataset ||= gobierto_data_datasets(:events_dataset)
        end

        def datasets_category
          @datasets_category ||= gobierto_common_custom_fields(:madrid_data_datasets_custom_field_category)
        end

        def other_site_dataset
          @other_site_dataset ||= gobierto_data_datasets(:santander_dataset)
        end

        def attachment
          @attachment ||= gobierto_attachments_attachments(:txt_pdf_attachment)
        end

        def array_data(dataset)
          [
            dataset.id.to_s,
            dataset.name,
            dataset.slug,
            dataset.table_name,
            dataset.data_updated_at.to_s,
            dataset.rails_model&.columns_hash&.transform_values(&:type)&.to_s,
            GobiertoCommon::CustomFieldRecord.find_by(item: dataset, custom_field: datasets_category)&.value_string
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
        def test_index_with_password_protected_site
          site.draft!
          site.configuration.password_protection_username = "username"
          site.configuration.password_protection_password = "password"

          %w(staging production).each do |environment|
            Rails.stub(:env, ActiveSupport::StringInquirer.new(environment)) do
              with(site: site) do
                get gobierto_data_api_v1_datasets_path, as: :json
                assert_response :unauthorized

                get gobierto_data_api_v1_datasets_path, as: :json, headers: { "Authorization" => basic_auth_header }
                assert_response :unauthorized

                admin.regular!
                admin.admin_sites.create(site: site)
                get gobierto_data_api_v1_datasets_path, as: :json, headers: { "Authorization" => admin_auth_header }
                assert_response :success

                admin.admin_sites.destroy_all
                get gobierto_data_api_v1_datasets_path, as: :json, headers: { "Authorization" => admin_auth_header }
                assert_response :unauthorized

                admin.manager!
                get gobierto_data_api_v1_datasets_path, as: :json, headers: { "Authorization" => admin_auth_header }
                assert_response :success
              end
            end
          end
        end

        def test_index_with_internal_site_request
          site.draft!
          site.configuration.password_protection_username = "username"
          site.configuration.password_protection_password = "password"

          %w(staging production).each do |environment|
            Rails.stub(:env, ActiveSupport::StringInquirer.new(environment)) do
              with(site: site) do
                self.host = "santander.gobierto.test"
                get gobierto_data_api_v1_datasets_path, as: :json
                assert_response :success

                get gobierto_data_api_v1_datasets_path, as: :json, headers: { "Authorization" => basic_auth_header }
                assert_response :success

                get gobierto_data_api_v1_datasets_path, as: :json, headers: { "Authorization" => "Bearer #{token_with_domain}" }
                assert_response :success

                get gobierto_data_api_v1_datasets_path, as: :json, headers: { "Authorization" => "Bearer #{token_with_other_domain}" }
                assert_response :success
              end
            end
          end
        end

        def test_index_with_domain_token
          site.draft!
          site.configuration.password_protection_username = "username"
          site.configuration.password_protection_password = "password"

          %w(staging production).each do |environment|
            Rails.stub(:env, ActiveSupport::StringInquirer.new(environment)) do
              with(site: site) do
                get gobierto_data_api_v1_datasets_path, as: :json
                assert_response :unauthorized

                get gobierto_data_api_v1_datasets_path, as: :json, headers: { "Authorization" => basic_auth_header }
                assert_response :unauthorized

                self.host = token_with_domain.domain
                get gobierto_data_api_v1_datasets_path, as: :json, headers: { "Authorization" => "Bearer #{token_with_domain}" }
                assert_response :success

                get gobierto_data_api_v1_datasets_path, as: :json, headers: { "Authorization" => "Bearer #{token_with_other_domain}" }
                assert_response :unauthorized

                self.host = token_with_other_domain.domain
                get gobierto_data_api_v1_datasets_path, as: :json, headers: { "Authorization" => "Bearer #{token_with_domain}" }
                assert_response :unauthorized

                get gobierto_data_api_v1_datasets_path, as: :json, headers: { "Authorization" => "Bearer #{token_with_other_domain}" }
                assert_response :success
              end
            end
          end
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
            assert_equal [dataset.name, other_dataset.name], datasets_names

            other_dataset.update_attribute(:data_updated_at, 1.second.ago)

            get gobierto_data_api_v1_datasets_path, as: :json
            response_data = response.parsed_body
            datasets_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            assert_equal [other_dataset.name, dataset.name], datasets_names
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
            assert_equal %w(id name slug table_name data_updated_at columns category), parsed_csv.first
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
            assert_equal %w(id name slug table_name data_updated_at columns category), sheet[0].cells.map(&:value)
            values = (1..active_datasets_count).map do |row_number|
              sheet[row_number].cells.map { |cell| cell.value.to_s }
            end
            assert_includes values, array_data(dataset)
            refute_includes values, array_data(other_site_dataset)
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

        # GET /api/v1/data/datasets/dataset-slug.xlsx
        def test_dataset_data_as_xlsx
          with(site: site) do
            get gobierto_data_api_v1_dataset_path(dataset.slug, format: :xlsx), as: :xlsx

            assert_response :success

            parsed_xlsx = RubyXL::Parser.parse_buffer response.parsed_body

            assert_equal 1, parsed_xlsx.worksheets.count
            sheet = parsed_xlsx.worksheets.first
            refute_nil sheet[dataset.rails_model.count]
            assert_nil sheet[dataset.rails_model.count + 1]
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
            %w(name slug data_updated_at data_summary columns formats).each do |attribute|
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

        # GET /api/v1/data/datasets/dataset-slug/download.json
        def test_dataset_download_as_json
          with(site: site) do
            get download_gobierto_data_api_v1_dataset_path(dataset.slug, format: :json), as: :json

            assert_response :success
            assert_match(/attachment; filename="?#{dataset.slug}.json"?/, response.headers["content-disposition"])
            response_data = response.parsed_body

            assert_equal dataset.rails_model.count, response_data.count
            assert_equal dataset.rails_model.all.map(&:id).sort, response_data.map { |row| row["id"] }.sort
          end
        end

        # GET /api/v1/data/datasets/dataset-slug/download.csv
        def test_dataset_download_as_csv
          with(site: site) do
            get download_gobierto_data_api_v1_dataset_path(dataset.slug, format: :csv), as: :csv

            assert_response :success
            assert_match(/attachment; filename="?#{dataset.slug}.csv"?/, response.headers["content-disposition"])
            response_data = response.parsed_body
            parsed_csv = CSV.parse(response_data)

            assert_equal dataset.rails_model.count + 1, parsed_csv.count
          end
        end

        # GET /api/v1/data/datasets/dataset-slug/download.xlsx
        def test_dataset_download_as_xlsx
          with(site: site) do
            get download_gobierto_data_api_v1_dataset_path(dataset.slug, format: :xlsx), as: :xlsx

            assert_response :success
            assert_match(/attachment; filename="?#{dataset.slug}.xlsx"?/, response.headers["content-disposition"])
            parsed_xlsx = RubyXL::Parser.parse_buffer response.parsed_body

            assert_equal 1, parsed_xlsx.worksheets.count
            sheet = parsed_xlsx.worksheets.first
            refute_nil sheet[dataset.rails_model.count]
            assert_nil sheet[dataset.rails_model.count + 1]
          end
        end

      end
    end
  end
end
