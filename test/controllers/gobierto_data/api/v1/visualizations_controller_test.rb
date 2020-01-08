# frozen_string_literal: true

require "test_helper"

module GobiertoData
  module Api
    module V1
      class VisualizationsControllerTest < GobiertoControllerTest

        def site
          @site ||= sites(:madrid)
        end

        def site_with_module_disabled
          @site_with_module_disabled ||= sites(:santander)
        end

        def user
          @user ||= users(:dennis)
        end

        def visualization
          @visualization ||= gobierto_data_visualizations(:users_count_visualization)
        end
        alias open_visualization visualization
        alias user_visualization visualization
        alias query_visualization visualization
        alias dataset_visualization visualization

        def closed_visualization
          @closed_visualization ||= gobierto_data_visualizations(:events_count_closed_visualization)
        end

        def other_dataset_visualization
          @other_dataset_visualization ||= gobierto_data_visualizations(:events_count_open_visualization)
        end

        def other_query_visualization
          @other_query_visualization ||= gobierto_data_visualizations(:census_verified_users_visualization)
        end
        alias other_user_visualization other_query_visualization

        def query
          @query ||= gobierto_data_queries(:users_count_query)
        end

        def other_query
          @other_query ||= gobierto_data_queries(:census_verified_user_query)
        end

        def other_dataset_query
          @other_dataset_query ||= gobierto_data_queries(:events_count_query)
        end

        def dataset
          @dataset ||= gobierto_data_datasets(:users_dataset)
        end

        def other_dataset
          @other_dataset ||= gobierto_data_datasets(:events_dataset)
        end

        def visualizations_count
          @visualizations_count ||= site.visualizations.count
        end

        def open_visualizations_count
          @open_visualizations_count ||= site.visualizations.open.count
        end

        def attributes_data(visualization)
          {
            id: visualization.id,
            name: visualization.name,
            name_translations: visualization.name_translations,
            privacy_status: visualization.privacy_status,
            spec: visualization.spec,
            query_id: visualization.query_id,
            user_id: visualization.user_id
          }.with_indifferent_access
        end

        def array_data(visualization)
          attributes = attributes_data(visualization)
          [
            attributes[:id].to_s,
            attributes[:name],
            attributes[:privacy_status],
            attributes[:spec].to_s,
            attributes[:query_id].to_s,
            attributes[:user_id].to_s
          ]
        end

        def valid_params
          {
            data:
            {
              type: "gobierto_data-visualizations",
              attributes:
              {
                name_translations: {
                  en: "New visualization",
                  es: "Nueva visualización"
                },
                privacy_status: "open",
                spec: {
                  "x" => 1,
                  "y" => 2,
                  "z" => 3
                },
                query_id: query.id,
                user_id: user.id
              }
            }
          }
        end

        def test_index_with_module_disabled
          with(site: site_with_module_disabled) do
            get gobierto_data_api_v1_visualizations_path

            assert_response :forbidden
          end
        end

        # GET /api/v1/data/visualizations.json
        def test_index_as_json
          with(site: site) do
            get gobierto_data_api_v1_visualizations_path, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            refute_equal visualizations_count, response_data["data"].count
            assert_equal open_visualizations_count, response_data["data"].count
            visualizations_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            assert_includes visualizations_names, open_visualization.name
            refute_includes visualizations_names, closed_visualization.name
            assert response_data.has_key? "links"
            links = response_data["links"].values
            assert_includes links, gobierto_data_api_v1_visualizations_path
            assert_includes links, new_gobierto_data_api_v1_visualization_path
          end
        end

        # GET /api/v1/data/visualizations.csv
        def test_index_as_csv
          with(site: site) do
            get gobierto_data_api_v1_visualizations_path(format: :csv), as: :csv

            assert_response :success

            response_data = response.parsed_body
            parsed_csv = CSV.parse(response_data)

            refute_equal visualizations_count + 1, parsed_csv.count
            assert_equal open_visualizations_count + 1, parsed_csv.count
            assert_equal %w(id name privacy_status spec query_id user_id), parsed_csv.first
            assert_includes parsed_csv, array_data(open_visualization)
            refute_includes parsed_csv, array_data(closed_visualization)
          end
        end

        # GET /api/v1/data/visualizations.csv
        def test_index_csv_format_separator
          with(site: site) do
            get gobierto_data_api_v1_visualizations_path(csv_separator: "semicolon", format: :csv), as: :csv

            assert_response :success

            parsed_csv_with_semicolon = CSV.parse(response.parsed_body, col_sep: ";")

            get gobierto_data_api_v1_visualizations_path(format: :csv), as: :csv
            default_parsed_csv = CSV.parse(response.parsed_body)

            assert_equal parsed_csv_with_semicolon, default_parsed_csv
          end
        end

        # GET /api/v1/data/visualizations.xlsx
        def test_index_xlsx_format
          with(site: site) do
            get gobierto_data_api_v1_visualizations_path(format: :xlsx), as: :xlsx

            assert_response :success

            parsed_xlsx = RubyXL::Parser.parse_buffer response.parsed_body

            assert_equal 1, parsed_xlsx.worksheets.count
            sheet = parsed_xlsx.worksheets.first
            assert_nil sheet[open_visualizations_count + 1]
            assert_equal %w(id name privacy_status spec query_id user_id), sheet[0].cells.map(&:value)
            values = (1..open_visualizations_count).map do |row_number|
              sheet[row_number].cells.map { |cell| cell.value.to_s }
            end
            assert_includes values, array_data(open_visualization)
            refute_includes values, array_data(closed_visualization)
          end
        end

        # GET /api/v1/data/queries.json?dataset_id=1
        def test_index_filtered_by_dataset
          with(site: site) do
            get gobierto_data_api_v1_visualizations_path(filter: { dataset_id: dataset.id }), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            visualizations_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            assert_includes visualizations_names, dataset_visualization.name
            assert_includes visualizations_names, other_query_visualization.name
            refute_includes visualizations_names, other_dataset_visualization.name
            refute_includes visualizations_names, closed_visualization.name
          end
        end

        # GET /api/v1/data/queries.json?query_id=1
        def test_index_filtered_by_query
          with(site: site) do
            get gobierto_data_api_v1_visualizations_path(filter: { query_id: query.id }), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            visualizations_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            assert_includes visualizations_names, query_visualization.name
            refute_includes visualizations_names, other_query_visualization.name
            refute_includes visualizations_names, other_dataset_visualization.name
            refute_includes visualizations_names, closed_visualization.name
          end
        end

        # GET /api/v1/data/queries.json?user_id=1
        def test_index_filtered_by_user
          with(site: site) do
            get gobierto_data_api_v1_visualizations_path(filter: { user_id: user.id }), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            visualizations_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            assert_includes visualizations_names, user_visualization.name
            assert_includes visualizations_names, other_dataset_visualization.name
            refute_includes visualizations_names, other_user_visualization.name
            refute_includes visualizations_names, closed_visualization.name
          end
        end

        # GET /api/v1/data/visualizations/1.json
        def test_show
          with(site: site) do
            get gobierto_data_api_v1_visualization_path(visualization), as: :json

            assert_response :success
            response_data = response.parsed_body

            # data
            assert response_data.has_key? "data"
            resource_data = response_data["data"]
            assert_equal resource_data["id"], visualization.id.to_s

            # attributes
            attributes = attributes_data(visualization)
            %w(name privacy_status spec query_id user_id).each do |attribute|
              assert resource_data["attributes"].has_key? attribute
              assert_equal attributes[attribute], resource_data["attributes"][attribute]
            end

            # relationships
            assert resource_data.has_key? "relationships"
            resource_relationships = resource_data["relationships"]
            assert resource_relationships.has_key? "user"
            assert resource_relationships.has_key? "query"

            # links
            assert response_data.has_key? "links"
            links = response_data["links"].values
            assert_includes links, gobierto_data_api_v1_visualizations_path
            assert_includes links, new_gobierto_data_api_v1_visualization_path
            assert_includes links, gobierto_data_api_v1_visualization_path(visualization)
          end
        end

        # GET /api/v1/data/visualizations/new
        def test_new
          with(site: site) do
            get new_gobierto_data_api_v1_visualization_path, as: :json

            assert_response :success
            response_data = response.parsed_body

            # data
            assert response_data.has_key? "data"
            resource_data = response_data["data"]

            # attributes
            %w(name_translations privacy_status spec query_id user_id).each do |attribute|
              assert resource_data["attributes"].has_key? attribute
            end

            # links
            assert response_data.has_key? "links"
            links = response_data["links"].values
            assert_includes links, gobierto_data_api_v1_visualizations_path
            assert_includes links, new_gobierto_data_api_v1_visualization_path
          end
        end

        # POST /api/v1/data/visualizations
        def test_create
          with(site: site) do
            assert_difference "GobiertoData::Visualization.count", 1 do
              post gobierto_data_api_v1_visualizations_path, params: valid_params, as: :json

              assert_response :created
              response_data = response.parsed_body

              new_visualization = Visualization.last
              # data
              assert response_data.has_key? "data"
              resource_data = response_data["data"]
              assert_equal resource_data["id"], new_visualization.id.to_s

              # attributes
              attributes = attributes_data(new_visualization)
              %w(name_translations privacy_status spec query_id user_id).each do |attribute|
                assert resource_data["attributes"].has_key? attribute
                assert_equal attributes[attribute], resource_data["attributes"][attribute]
              end

              # relationships
              assert resource_data.has_key? "relationships"

              # links
              assert response_data.has_key? "links"
              links = response_data["links"].values
              assert_includes links, gobierto_data_api_v1_visualizations_path
              assert_includes links, new_gobierto_data_api_v1_visualization_path
              assert_includes links, gobierto_data_api_v1_visualization_path(new_visualization)
            end
          end
        end

        # POST /api/v1/data/visualizations
        def test_create_invalid_params
          with(site: site) do
            post gobierto_data_api_v1_visualizations_path, params: {}, as: :json

            assert_response :unprocessable_entity
            response_data = response.parsed_body

            assert response_data.has_key? "errors"
          end
        end

        # PUT /api/v1/data/queries/1
        def test_update
          with(site: site) do
            assert_no_difference "GobiertoData::Visualization.count" do
              put gobierto_data_api_v1_visualization_path(visualization), params: valid_params, as: :json

              assert_response :success
              response_data = response.parsed_body

              # data
              assert response_data.has_key? "data"
              resource_data = response_data["data"]
              assert_equal resource_data["id"], visualization.id.to_s

              # attributes
              attributes = valid_params[:data][:attributes].with_indifferent_access
              %w(name_translations privacy_status spec query_id user_id).each do |attribute|
                assert resource_data["attributes"].has_key? attribute
                assert_equal attributes[attribute], resource_data["attributes"][attribute]
              end

              # relationships
              assert resource_data.has_key? "relationships"

              # links
              assert response_data.has_key? "links"
              links = response_data["links"].values
              assert_includes links, gobierto_data_api_v1_visualizations_path
              assert_includes links, new_gobierto_data_api_v1_visualization_path
              assert_includes links, gobierto_data_api_v1_visualization_path(visualization)
            end
          end
        end

        # PUT /api/v1/data/queries/1
        def test_update_invalid_params
          with(site: site) do
            put gobierto_data_api_v1_visualization_path(visualization), params: {}, as: :json

            assert_response :unprocessable_entity
            response_data = response.parsed_body

            assert response_data.has_key? "errors"
          end
        end

        # DELETE /api/v1/data/queries/1
        def test_delete
          id = visualization.id
          assert_difference "GobiertoData::Visualization.count", -1 do
            with(site: site) do
              delete gobierto_data_api_v1_visualization_path(id), as: :json

              assert_response :no_content

              assert_nil Visualization.find_by(id: id)
            end
          end
        end

      end
    end
  end
end
