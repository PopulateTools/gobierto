# frozen_string_literal: true

require "test_helper"

module GobiertoData
  module Api
    module V1
      class QueriesControllerTest < GobiertoControllerTest

        def site
          @site ||= sites(:madrid)
        end

        def site_with_module_disabled
          @site_with_module_disabled ||= sites(:santander)
        end

        def user
          @user ||= users(:dennis)
        end

        def query
          @query ||= gobierto_data_queries(:users_count_query)
        end
        alias open_query query
        alias user_query query
        alias dataset_query query

        def closed_query
          @closed_query ||= gobierto_data_queries(:census_verified_users_query)
        end
        alias other_user_query closed_query

        def other_dataset_query
          @other_dataset_query ||= gobierto_data_queries(:events_count_query)
        end

        def dataset
          @dataset ||= gobierto_data_datasets(:users_dataset)
        end

        def other_dataset
          @other_dataset ||= gobierto_data_datasets(:events_dataset)
        end

        def queries_count
          @queries_count ||= site.queries.count
        end

        def open_queries_count
          @open_queries_count ||= site.queries.open.count
        end

        def attributes_data(query)
          {
            id: query.id,
            name: query.name,
            name_translations: query.name_translations,
            privacy_status: query.privacy_status,
            sql: query.sql,
            dataset_id: query.dataset_id,
            user_id: query.user_id
          }.with_indifferent_access
        end

        def array_data(query)
          attributes = attributes_data(query)
          [
            attributes[:id].to_s,
            attributes[:name],
            attributes[:privacy_status],
            attributes[:sql],
            attributes[:dataset_id].to_s,
            attributes[:user_id].to_s
          ]
        end

        def valid_params
          {
            data:
            {
              type: "gobierto_data-queries",
              attributes:
              {
                name_translations: {
                  en: "Users with bio",
                  es: "Usuarios con bio"
                },
                privacy_status: "open",
                sql: "select count(*) from users where bio is not null",
                dataset_id: dataset.id,
                user_id: user.id
              }
            }
          }
        end

        def test_index_with_module_disabled
          with(site: site_with_module_disabled) do
            get gobierto_data_api_v1_queries_path

            assert_response :forbidden
          end
        end

        # GET /api/v1/data/queries.json
        def test_index_as_json
          with(site: site) do
            get gobierto_data_api_v1_queries_path, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            refute_equal queries_count, response_data["data"].count
            assert_equal open_queries_count, response_data["data"].count
            queries_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            assert_includes queries_names, open_query.name
            refute_includes queries_names, closed_query.name
            assert response_data.has_key? "links"
            links = response_data["links"].values
            assert_includes links, gobierto_data_api_v1_queries_path
            assert_includes links, new_gobierto_data_api_v1_query_path
            assert_includes links, gobierto_data_api_v1_visualizations_path
          end
        end

        # GET /api/v1/data/queries.csv
        def test_index_as_csv
          with(site: site) do
            get gobierto_data_api_v1_queries_path(format: :csv), as: :csv

            assert_response :success

            response_data = response.parsed_body
            parsed_csv = CSV.parse(response_data)

            refute_equal queries_count + 1, parsed_csv.count
            assert_equal open_queries_count + 1, parsed_csv.count
            assert_equal %w(id name privacy_status sql dataset_id user_id), parsed_csv.first
            assert_includes parsed_csv, array_data(open_query)
            refute_includes parsed_csv, array_data(closed_query)
          end
        end

        # GET /api/v1/data/queries.csv
        def test_index_csv_format_separator
          with(site: site) do
            get gobierto_data_api_v1_queries_path(csv_separator: "semicolon", format: :csv), as: :csv

            assert_response :success

            parsed_csv_with_semicolon = CSV.parse(response.parsed_body, col_sep: ";")

            get gobierto_data_api_v1_queries_path(format: :csv), as: :csv
            default_parsed_csv = CSV.parse(response.parsed_body)

            assert_equal parsed_csv_with_semicolon, default_parsed_csv
          end
        end

        # GET /api/v1/data/queries.xlsx
        def test_index_xlsx_format
          with(site: site) do
            get gobierto_data_api_v1_queries_path(format: :xlsx), as: :xlsx

            assert_response :success

            parsed_xlsx = RubyXL::Parser.parse_buffer response.parsed_body

            assert_equal 1, parsed_xlsx.worksheets.count
            sheet = parsed_xlsx.worksheets.first
            assert_nil sheet[open_queries_count + 1]
            assert_equal %w(id name privacy_status sql dataset_id user_id), sheet[0].cells.map(&:value)
            values = (1..open_queries_count).map do |row_number|
              sheet[row_number].cells.map { |cell| cell.value.to_s }
            end
            assert_includes values, array_data(open_query)
            refute_includes values, array_data(closed_query)
          end
        end

        # GET /api/v1/data/queries.json?dataset_id=1
        def test_index_filtered_by_dataset
          with(site: site) do
            get gobierto_data_api_v1_queries_path(filter: { dataset_id: dataset.id }), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            queries_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            assert_includes queries_names, dataset_query.name
            refute_includes queries_names, other_dataset_query.name
            refute_includes queries_names, closed_query.name
          end
        end

        # GET /api/v1/data/queries.json?user_id=1
        def test_index_filtered_by_user
          with(site: site) do
            get gobierto_data_api_v1_queries_path(filter: { user_id: user.id }), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            queries_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            assert_includes queries_names, user_query.name
            assert_includes queries_names, other_dataset_query.name
            refute_includes queries_names, closed_query.name
          end
        end

        # GET /api/v1/data/queries.json?user_id=1&dataset_id=1
        def test_index_filtered_by_user_and_dataset
          with(site: site) do
            get gobierto_data_api_v1_queries_path(filter: { dataset_id: other_dataset.id, user_id: user.id }), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            queries_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            assert_includes queries_names, other_dataset_query.name
            refute_includes queries_names, user_query.name
            refute_includes queries_names, closed_query.name
          end
        end

        # GET /api/v1/data/queries/1.json
        def test_query_data
          with(site: site) do
            get gobierto_data_api_v1_query_path(query), as: :json

            assert_response :success
            response_data = response.parsed_body
            assert response_data.has_key? "data"
            assert_equal 1, response_data["data"].count
            assert_equal [{ "count" => 7 }], response_data["data"]

            assert response_data.has_key? "meta"
            assert response_data.has_key? "links"
            links = response_data["links"].values
            assert_includes links, gobierto_data_api_v1_queries_path
            assert_includes links, new_gobierto_data_api_v1_query_path
            assert_includes links, gobierto_data_api_v1_query_path(query)
            assert_includes links, meta_gobierto_data_api_v1_query_path(query)
            assert_includes links, gobierto_data_api_v1_visualizations_path(filter: { query_id: query.id })
          end
        end

        # GET /api/v1/data/queries/1.csv
        def test_query_data_as_csv
          with(site: site) do
            get gobierto_data_api_v1_query_path(query, format: :csv), as: :csv

            assert_response :success

            response_data = response.parsed_body
            parsed_csv = CSV.parse(response_data)

            assert_equal 2, parsed_csv.count
            assert_equal %w(count), parsed_csv.first
            assert_equal %w(7), parsed_csv.last
          end
        end

        # GET /api/v1/data/queries/1.xlsx
        def test_query_data_as_xlsx
          with(site: site) do
            get gobierto_data_api_v1_query_path(query, format: :xlsx), as: :xlsx

            assert_response :success

            parsed_xlsx = RubyXL::Parser.parse_buffer response.parsed_body

            assert_equal 1, parsed_xlsx.worksheets.count
            sheet = parsed_xlsx.worksheets.first
            assert_nil sheet[2]
            assert_equal %w(count), sheet[0].cells.map(&:value)
            assert_equal [7], sheet[1].cells.map(&:value)
          end
        end

        # GET /api/v1/data/queries/1/meta
        def test_query_metadata
          with(site: site) do
            get meta_gobierto_data_api_v1_query_path(query), as: :json

            assert_response :success
            response_data = response.parsed_body

            # data
            assert response_data.has_key? "data"
            resource_data = response_data["data"]
            assert_equal resource_data["id"], query.id.to_s

            # attributes
            attributes = attributes_data(query)
            %w(name privacy_status sql dataset_id user_id).each do |attribute|
              assert resource_data["attributes"].has_key? attribute
              assert_equal attributes[attribute], resource_data["attributes"][attribute]
            end

            # relationships
            assert resource_data.has_key? "relationships"
            resource_relationships = resource_data["relationships"]
            assert resource_relationships.has_key? "user"
            assert resource_relationships.has_key? "dataset"
            assert resource_relationships.has_key? "visualizations"

            # links
            assert response_data.has_key? "links"
            links = response_data["links"].values
            assert_includes links, gobierto_data_api_v1_queries_path
            assert_includes links, new_gobierto_data_api_v1_query_path
            assert_includes links, gobierto_data_api_v1_query_path(query)
            assert_includes links, meta_gobierto_data_api_v1_query_path(query)
            assert_includes links, gobierto_data_api_v1_visualizations_path(filter: { query_id: query.id })
          end
        end

        # GET /api/v1/data/queries/new
        def test_new
          with(site: site) do
            get new_gobierto_data_api_v1_query_path, as: :json

            assert_response :success
            response_data = response.parsed_body

            # data
            assert response_data.has_key? "data"
            resource_data = response_data["data"]

            # attributes
            %w(name_translations privacy_status sql dataset_id user_id).each do |attribute|
              assert resource_data["attributes"].has_key? attribute
            end

            # links
            assert response_data.has_key? "links"
            links = response_data["links"].values
            assert_includes links, gobierto_data_api_v1_queries_path
            assert_includes links, new_gobierto_data_api_v1_query_path
          end
        end

        # POST /api/v1/data/queries
        def test_create
          with(site: site) do
            assert_difference "GobiertoData::Query.count", 1 do
              post gobierto_data_api_v1_queries_path, params: valid_params, as: :json

              assert_response :created
              response_data = response.parsed_body

              new_query = Query.last
              # data
              assert response_data.has_key? "data"
              resource_data = response_data["data"]
              assert_equal resource_data["id"], new_query.id.to_s

              # attributes
              attributes = attributes_data(new_query)
              %w(name_translations privacy_status sql dataset_id user_id).each do |attribute|
                assert resource_data["attributes"].has_key? attribute
                assert_equal attributes[attribute], resource_data["attributes"][attribute]
              end

              # relationships
              assert resource_data.has_key? "relationships"

              # links
              assert response_data.has_key? "links"
              links = response_data["links"].values
              assert_includes links, gobierto_data_api_v1_queries_path
              assert_includes links, new_gobierto_data_api_v1_query_path
              assert_includes links, gobierto_data_api_v1_query_path(new_query)
              assert_includes links, meta_gobierto_data_api_v1_query_path(new_query)
              assert_includes links, gobierto_data_api_v1_visualizations_path(filter: { query_id: new_query.id })
            end
          end
        end

        # POST /api/v1/data/queries
        def test_create_invalid_params
          with(site: site) do
            post gobierto_data_api_v1_queries_path, params: {}, as: :json

            assert_response :unprocessable_entity
            response_data = response.parsed_body

            assert response_data.has_key? "errors"
          end
        end

        # PUT /api/v1/data/queries/1
        def test_update
          with(site: site) do
            assert_no_difference "GobiertoData::Query.count" do
              put gobierto_data_api_v1_query_path(query), params: valid_params, as: :json

              assert_response :success
              response_data = response.parsed_body

              # data
              assert response_data.has_key? "data"
              resource_data = response_data["data"]
              assert_equal resource_data["id"], query.id.to_s

              # attributes
              attributes = valid_params[:data][:attributes].with_indifferent_access
              %w(name_translations privacy_status sql dataset_id user_id).each do |attribute|
                assert resource_data["attributes"].has_key? attribute
                assert_equal attributes[attribute], resource_data["attributes"][attribute]
              end

              # relationships
              assert resource_data.has_key? "relationships"

              # links
              assert response_data.has_key? "links"
              links = response_data["links"].values
              assert_includes links, gobierto_data_api_v1_queries_path
              assert_includes links, new_gobierto_data_api_v1_query_path
              assert_includes links, gobierto_data_api_v1_query_path(query)
              assert_includes links, meta_gobierto_data_api_v1_query_path(query)
              assert_includes links, gobierto_data_api_v1_visualizations_path(filter: { query_id: query.id })
            end
          end
        end

        # PUT /api/v1/data/queries/1
        def test_update_invalid_params
          with(site: site) do
            put gobierto_data_api_v1_query_path(query), params: {}, as: :json

            assert_response :unprocessable_entity
            response_data = response.parsed_body

            assert response_data.has_key? "errors"
          end
        end

        # DELETE /api/v1/data/queries/1
        def test_delete
          id = query.id
          assert_difference "GobiertoData::Query.count", -1 do
            with(site: site) do
              delete gobierto_data_api_v1_query_path(id), as: :json

              assert_response :no_content

              assert_nil Query.find_by(id: id)
            end
          end
        end

      end
    end
  end
end
