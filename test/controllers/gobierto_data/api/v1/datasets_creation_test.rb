# frozen_string_literal: true

require "test_helper"

module GobiertoData
  module Api
    module V1
      class DatasetsCreationControllerTest < GobiertoControllerTest
        self.use_transactional_tests = false

        def auth_header
          @auth_header ||= "Bearer #{admin.primary_api_token}"
        end

        def site
          @site ||= sites(:madrid)
        end

        def site_with_module_disabled
          @site_with_module_disabled ||= sites(:santander)
        end

        def admin
          @admin ||= gobierto_admin_admins(:tony)
        end

        def admin_without_last_sign_in_ip_auth_header
          @admin_without_last_sign_in_ip_auth_header ||= "Bearer #{gobierto_admin_admins(:steve).primary_api_token}"
        end

        def module_settings
          @module_settings ||= gobierto_module_settings(:gobierto_data_settings_madrid)
        end

        def multipart_form_params(file = "dataset1.csv", **opts)
          {
            dataset: {
              name: "Uploaded dataset",
              table_name: "uploaded_dataset",
              data_file: Rack::Test::UploadedFile.new("#{Rails.root}/test/fixtures/files/gobierto_data/#{file}"),
              visibility_level: "active"
            }.merge(opts)
          }
        end

        # POST /api/v1/data/datasets
        #
        def test_dataset_creation_with_missing_params
          with(site: site) do
            assert_no_difference "GobiertoData::Dataset.count" do
              post(
                gobierto_data_api_v1_datasets_path,
                params: multipart_form_params("dataset1.csv").deep_merge(
                  dataset: { name: nil, table_name: nil }
                ),
                headers: { "Authorization" => auth_header }
              )

              assert_response :unprocessable_entity
              response_data = response.parsed_body
              assert_match(/can't be blank/, response_data.to_s)
              refute site.activities.where(subject_type: "GobiertoData::Dataset").exists?
            end
          end
        end

        # POST /api/v1/data/datasets
        #
        def test_dataset_creation_with_module_database_configuration_missing
          module_settings.update_attribute(:settings, {})

          with(site: site) do
            assert_no_difference "GobiertoData::Dataset.count" do
              post(
                gobierto_data_api_v1_datasets_path,
                params: multipart_form_params("dataset1.csv"),
                headers: { "Authorization" => auth_header }
              )

              assert_response :unprocessable_entity
              response_data = response.parsed_body
              assert_match(/Database configuration missing/, response_data.to_s)
              refute site.activities.where(subject_type: "GobiertoData::Dataset").exists?
            end
          end
        end

        # POST /api/v1/data/datasets
        #
        def test_dataset_creation_with_invalid_file_upload
          with(site: site) do
            assert_no_difference "GobiertoData::Dataset.count" do
              post(
                gobierto_data_api_v1_datasets_path,
                params: multipart_form_params("schema.json"),
                headers: { "Authorization" => auth_header }
              )

              assert_response :unprocessable_entity
              response_data = response.parsed_body
              assert_match(/Database error loading CSV/, response_data.to_s)
              refute site.activities.where(subject_type: "GobiertoData::Dataset").exists?
            end
          end
        end

        # POST /api/v1/data/datasets
        #
        def test_dataset_creation_with_blank_csv_separator
          with(site: site) do
            assert_no_difference "GobiertoData::Dataset.count" do
              post(
                gobierto_data_api_v1_datasets_path,
                params: multipart_form_params("dataset1.csv", csv_separator: ""),
                headers: { "Authorization" => auth_header }
              )

              assert_response :unprocessable_entity
              response_data = response.parsed_body
              assert_match(/wrong length \(should be 1 character\)/, response_data.to_s)
              refute site.activities.where(subject_type: "GobiertoData::Dataset").exists?
            end
          end
        end

        # POST /api/v1/data/datasets
        #
        def test_dataset_creation_with_upload_missing
          ::Mime::Type.any_instance.stubs(:symbol).returns(:multipart_form)

          with(site: site) do
            assert_no_difference "GobiertoData::Dataset.count" do
              post(
                gobierto_data_api_v1_datasets_path,
                params: multipart_form_params("dataset1.csv", data_file: "/User/local/file.csv"),
                headers: { "Authorization" => auth_header }
              )

              assert_response :unprocessable_entity
              response_data = response.parsed_body
              assert_match(/The file hasn't been uploaded/, response_data.to_s)
              refute site.activities.where(subject_type: "GobiertoData::Dataset").exists?
            end
          end
        end

        # POST /api/v1/data/datasets
        #
        def test_dataset_creation_with_password_protected_site_and_admin_auth_header
          site.draft!
          site.configuration.password_protection_username = "username"
          site.configuration.password_protection_password = "password"

          %w(staging production).each do |environment|
            Rails.stub(:env, ActiveSupport::StringInquirer.new(environment)) do
              with(site: site) do
                post(
                  gobierto_data_api_v1_datasets_path,
                  params: multipart_form_params("dataset1.csv", table_name: "uploaded_dataset_#{environment}"),
                  headers: { "Authorization" => auth_header }
                )

                assert_response :created
              end
            end
          end
        end

        # POST /api/v1/data/datasets
        #
        def test_dataset_creation_with_password_protected_site_and_basic_auth_header
          site.draft!
          site.configuration.password_protection_username = "username"
          site.configuration.password_protection_password = "password"
          basic_auth_header = "Basic #{Base64.encode64("username:password")}"

          %w(staging production).each do |environment|
            Rails.stub(:env, ActiveSupport::StringInquirer.new(environment)) do
              with(site: site) do
                post(
                  gobierto_data_api_v1_datasets_path,
                  params: multipart_form_params("dataset1.csv", table_name: "uploaded_dataset_#{environment}"),
                  headers: { "Authorization" => basic_auth_header }
                )

                assert_response :unauthorized
              end
            end
          end
        end

        # POST /api/v1/data/datasets
        #
        def test_dataset_creation_with_file_upload
          with(site: site) do
            post(
              gobierto_data_api_v1_datasets_path,
              params: multipart_form_params("dataset1.csv"),
              headers: { "Authorization" => auth_header }
            )

            assert site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_created").exists?
            refute site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_data_updated").exists?
            assert_response :created
            response_data = response.parsed_body
            attributes = response_data["data"]["attributes"].with_indifferent_access

            [:name, :table_name, :visibility_level].each do |attribute|
              assert_equal multipart_form_params[:dataset][attribute], attributes[attribute]
            end

            query_result = GobiertoData::Connection.execute_query(site, "select * from uploaded_dataset", include_stats: true)
            assert_equal 4, query_result[:rows]
            query_result[:result].first.each_value do |value|
              assert value.is_a? String
            end
          end
        end

        # POST /api/v1/data/datasets
        #
        def test_dataset_creation_with_iso8859_1_encoding
          with(site: site) do
            post(
              gobierto_data_api_v1_datasets_path,
              params: multipart_form_params("dataset_iso88591.csv").deep_merge(
                dataset: { csv_separator: ";" }
              ),
              headers: { "Authorization" => auth_header }
            )

            assert site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_created").exists?
            refute site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_data_updated").exists?
            assert_response :created
            response_data = response.parsed_body
            attributes = response_data["data"]["attributes"].with_indifferent_access

            [:name, :table_name, :visibility_level].each do |attribute|
              assert_equal multipart_form_params[:dataset][attribute], attributes[attribute]
            end

            query_result = GobiertoData::Connection.execute_query(site, "select * from uploaded_dataset", include_stats: true)
            assert_equal 29, query_result[:rows]
            query_result[:result].first.each_value do |value|
              assert value.is_a? String
            end

            query_result = GobiertoData::Connection.execute_query(site, "select * from uploaded_dataset where municipio_distrito like 'Alcor%'", include_stats: true)
            assert_equal 1, query_result[:rows]
            assert_equal "Alcorcón", query_result[:result].first["municipio_distrito"]
          end
        end

        # POST /api/v1/data/datasets
        #
        def test_dataset_creation_with_file_upload_and_schema_file_renaming_columns
          with(site: site) do
            post(
              gobierto_data_api_v1_datasets_path,
              params: multipart_form_params("dataset1.csv").deep_merge(
                dataset: { schema_file: Rack::Test::UploadedFile.new("#{Rails.root}/test/fixtures/files/gobierto_data/schema_rename_columns.json") }
              ),
              headers: { "Authorization" => auth_header }
            )

            assert site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_created").exists?
            refute site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_data_updated").exists?
            assert_response :created
            response_data = response.parsed_body
            attributes = response_data["data"]["attributes"].with_indifferent_access

            [:name, :table_name, :visibility_level].each do |attribute|
              assert_equal multipart_form_params[:dataset][attribute], attributes[attribute]
            end

            query_result = GobiertoData::Connection.execute_query(site, "select * from uploaded_dataset", include_stats: true)
            assert_equal 4, query_result[:rows]

            query_result[:result].first.each_key do |column_name|
              assert_match(/_changed\Z/, column_name)
            end
          end
        end

        # POST /api/v1/data/datasets
        #
        def test_dataset_creation_with_file_upload_and_malformed_schema_file
          with(site: site) do
            post(
              gobierto_data_api_v1_datasets_path,
              params: multipart_form_params("dataset1.csv").deep_merge(
                dataset: { schema_file: Rack::Test::UploadedFile.new("#{Rails.root}/test/fixtures/files/gobierto_data/malformed_schema.json") }
              ),
              headers: { "Authorization" => auth_header }
            )

            assert_response :unprocessable_entity
            response_data = response.parsed_body
            assert_match(/Malformed file/, response_data.to_s)
            refute site.activities.where(subject_type: "GobiertoData::Dataset").exists?
          end
        end

        # POST /api/v1/data/datasets
        #
        def test_dataset_creation_with_file_upload_and_schema_file_with_invalid_type
          with(site: site) do
            post(
              gobierto_data_api_v1_datasets_path,
              params: multipart_form_params("dataset1.csv").deep_merge(
                dataset: { schema_file: Rack::Test::UploadedFile.new("#{Rails.root}/test/fixtures/files/gobierto_data/invalid_type_schema.json") }
              ),
              headers: { "Authorization" => auth_header }
            )

            assert_response :unprocessable_entity
            response_data = response.parsed_body
            assert_match(/The type 'invent' is not defined/, response_data.to_s)
            refute site.activities.where(subject_type: "GobiertoData::Dataset").exists?
          end
        end

        # PUT /api/v1/data/datasets/dataset-slug
        #
        def test_dataset_update_with_file_upload
          with(site: site) do
            post(
              gobierto_data_api_v1_datasets_path,
              params: multipart_form_params("dataset1.csv"),
              headers: { "Authorization" => auth_header }
            )

            assert site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_created").exists?
            refute site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_data_updated").exists?
            assert_response :created
            response_data = response.parsed_body
            attributes = response_data["data"]["attributes"].with_indifferent_access
            slug = response_data["data"]["attributes"]["slug"]

            site.activities.where(subject_type: "GobiertoData::Dataset").destroy_all
            put(
              gobierto_data_api_v1_dataset_path(slug),
              params: multipart_form_params("dataset2.csv"),
              headers: { "Authorization" => auth_header }
            )

            refute site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_created").exists?
            refute site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_updated").exists?
            assert site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_data_updated").exists?
            assert_response :success
            response_data = response.parsed_body
            attributes = response_data["data"]["attributes"].with_indifferent_access

            [:name, :table_name, :visibility_level].each do |attribute|
              assert_equal multipart_form_params[:dataset][attribute], attributes[attribute]
            end

            query_result = GobiertoData::Connection.execute_query(site, "select * from uploaded_dataset", include_stats: true)
            assert_equal 1, query_result[:rows]
            query_result[:result].first.each_value do |value|
              assert value.is_a? String
            end
          end
        end

        # PUT /api/v1/data/datasets/dataset-slug
        #
        def test_dataset_update_with_file_upload_append
          with(site: site) do
            post(
              gobierto_data_api_v1_datasets_path,
              params: multipart_form_params("dataset1.csv"),
              headers: { "Authorization" => auth_header }
            )

            assert site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_created").exists?
            refute site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_data_updated").exists?
            assert_response :created
            response_data = response.parsed_body
            attributes = response_data["data"]["attributes"].with_indifferent_access
            slug = response_data["data"]["attributes"]["slug"]

            site.activities.where(subject_type: "GobiertoData::Dataset").destroy_all
            put(
              gobierto_data_api_v1_dataset_path(slug),
              params: multipart_form_params("dataset2.csv").deep_merge(dataset: { append: "true" }),
              headers: { "Authorization" => auth_header }
            )

            refute site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_created").exists?
            refute site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_updated").exists?
            assert site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_data_updated").exists?
            assert_response :success
            response_data = response.parsed_body
            attributes = response_data["data"]["attributes"].with_indifferent_access

            [:name, :table_name, :visibility_level].each do |attribute|
              assert_equal multipart_form_params[:dataset][attribute], attributes[attribute]
            end

            query_result = GobiertoData::Connection.execute_query(site, "select * from uploaded_dataset", include_stats: true)
            assert_equal 5, query_result[:rows]
            query_result[:result].first.each_value do |value|
              assert value.is_a? String
            end
          end
        end

        # PUT /api/v1/data/datasets/dataset-slug
        #
        def test_dataset_update_with_file_upload_append_with_schema
          with(site: site) do
            post(
              gobierto_data_api_v1_datasets_path,
              params: multipart_form_params("dataset1.csv").deep_merge(
                dataset: { schema_file: Rack::Test::UploadedFile.new("#{Rails.root}/test/fixtures/files/gobierto_data/schema.json") }
              ),
              headers: { "Authorization" => auth_header }
            )

            assert site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_created").exists?
            refute site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_data_updated").exists?
            assert_response :created
            response_data = response.parsed_body
            attributes = response_data["data"]["attributes"].with_indifferent_access
            slug = response_data["data"]["attributes"]["slug"]

            site.activities.where(subject_type: "GobiertoData::Dataset").destroy_all
            put(
              gobierto_data_api_v1_dataset_path(slug),
              params: multipart_form_params("dataset2.csv").deep_merge(dataset: { append: "true" }),
              headers: { "Authorization" => auth_header }
            )

            refute site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_created").exists?
            refute site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_updated").exists?
            assert site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_data_updated").exists?
            assert_response :success
            response_data = response.parsed_body
            attributes = response_data["data"]["attributes"].with_indifferent_access

            [:name, :table_name, :visibility_level].each do |attribute|
              assert_equal multipart_form_params[:dataset][attribute], attributes[attribute]
            end

            query_result = GobiertoData::Connection.execute_query(site, "select * from uploaded_dataset", include_stats: true)
            assert_equal 5, query_result[:rows]

            schema = Dataset.find_by_slug(slug).send(:table_schema)
            assert_equal "integer", schema["integer_column"]["type"]
            assert_equal "numeric", schema["decimal_column"]["type"]
            assert_equal "text", schema["text_column"]["type"]
            assert_equal "date", schema["date_column"]["type"]
          end
        end

        # POST /api/v1/data/datasets
        #
        def test_dataset_creation_with_admin_with_blank_last_sign_in_ip
          with(site: site) do
            post(
              gobierto_data_api_v1_datasets_path,
              params: multipart_form_params("dataset1.csv"),
              headers: { "Authorization" => admin_without_last_sign_in_ip_auth_header }
            )

            assert site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_created").exists?
            refute site.activities.where(subject_type: "GobiertoData::Dataset", action: "gobierto_data.dataset.dataset_data_updated").exists?
            assert_response :created
          end
        end

        # POST /api/v1/data/datasets
        #
        def test_dataset_create_with_boolean_columns
          with(site: site) do
            post(
              gobierto_data_api_v1_datasets_path,
              params: multipart_form_params("dataset_boolean_columns.csv").deep_merge(
                dataset: { schema_file: Rack::Test::UploadedFile.new("#{Rails.root}/test/fixtures/files/gobierto_data/schema_boolean_columns.json") }
              ),
              headers: { "Authorization" => auth_header }
            )

            assert_response :created
            query_result = GobiertoData::Connection.execute_query(site, "select * from uploaded_dataset", include_stats: true)
            assert_equal 6, query_result[:rows]
            assert_equal 1, query_result[:result][0]["id"]
            assert_equal "Ruby", query_result[:result][0]["name"]
            assert_equal true, query_result[:result][0]["is_cool"]
            assert_equal 2, query_result[:result][1]["id"]
            assert_equal "Javascript", query_result[:result][1]["name"]
            assert_equal false, query_result[:result][1]["is_cool"]
          end
        end

        # POST /api/v1/data/datasets
        #
        def test_dataset_create_with_boolean_columns_and_no_options
          with(site: site) do
            post(
              gobierto_data_api_v1_datasets_path,
              params: multipart_form_params("dataset_boolean_columns.csv").deep_merge(
                dataset: { schema_file: Rack::Test::UploadedFile.new("#{Rails.root}/test/fixtures/files/gobierto_data/schema_boolean_columns_without_options.json") }
              ),
              headers: { "Authorization" => auth_header }
            )

            assert_response :created
            query_result = GobiertoData::Connection.execute_query(site, "select * from uploaded_dataset", include_stats: true)
            assert_equal 6, query_result[:rows]
            assert_equal 1, query_result[:result][0]["id"]
            assert_equal "Ruby", query_result[:result][0]["name"]
            assert_equal true, query_result[:result][0]["is_cool"]
            assert_equal 2, query_result[:result][1]["id"]
            assert_equal "Javascript", query_result[:result][1]["name"]
            assert_equal false, query_result[:result][1]["is_cool"]
          end
        end

        # POST /api/v1/data/datasets
        #
        def test_dataset_create_with_boolean_columns_and_custom_values
          with(site: site) do
            post(
              gobierto_data_api_v1_datasets_path,
              params: multipart_form_params("dataset_boolean_custom_columns.csv").deep_merge(
                dataset: { schema_file: Rack::Test::UploadedFile.new("#{Rails.root}/test/fixtures/files/gobierto_data/schema_boolean_custom_columns.json") }
              ),
              headers: { "Authorization" => auth_header }
            )

            assert_response :created
            query_result = GobiertoData::Connection.execute_query(site, "select * from uploaded_dataset", include_stats: true)
            assert_equal 6, query_result[:rows]
            assert_equal 1, query_result[:result][0]["id"]
            assert_equal "Ruby", query_result[:result][0]["name"]
            assert_equal true, query_result[:result][0]["is_cool"]
            assert_equal 2, query_result[:result][1]["id"]
            assert_equal "Javascript", query_result[:result][1]["name"]
            assert_equal false, query_result[:result][1]["is_cool"]
          end
        end
      end
    end
  end
end
