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

        def user_token
          @user_token ||= "Bearer #{user_api_tokens(:dennis_primary_api_token)}"
        end

        def other_user
          @other_user ||= users(:peter)
        end

        def other_user_token
          @other_user_token ||= "Bearer #{user_api_tokens(:peter_primary_api_token)}"
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

        def other_user_closed_visualization
          @other_user_closed_visualization ||= gobierto_data_visualizations(:peter_events_count_closed_visualization)
        end

        def other_dataset_visualization
          @other_dataset_visualization ||= gobierto_data_visualizations(:events_count_open_visualization)
        end
        alias latest_visualization other_dataset_visualization

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

        def active_visualizations_count
          @active_visualizations_count ||= site.visualizations.active.count
        end

        def open_active_visualizations_count
          @open_active_visualizations_count ||= site.visualizations.active.open.count
        end

        def attributes_data(visualization)
          {
            id: visualization.id,
            name: visualization.name,
            name_translations: visualization.name_translations,
            privacy_status: visualization.privacy_status,
            spec: visualization.spec,
            sql: visualization.sql,
            query_id: visualization.query_id,
            dataset_id: visualization.dataset_id,
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
            attributes[:sql],
            attributes[:query_id].to_s,
            attributes[:dataset_id].to_s,
            attributes[:user_id].to_s
          ]
        end

        def valid_params(except: [])
          {
            data:
            {
              type: "gobierto_data-visualizations",
              attributes: valid_attributes.except(*except)
            }
          }
        end

        def valid_attributes
          {
            name_translations: {
              en: "New visualization",
              es: "Nueva visualización"
            },
            privacy_status: "open",
            sql: "select count(*) from users where bio is not null",
            spec: {
              "plugin": "d3_xy_scatter",
              "columns": [
                "column_1",
                "height",
                nil,
                nil,
                "birth_state",
                "birth_city"
              ],
              "selectable": nil,
              "editable": nil,
              "row-pivots": nil,
              "column-pivots": nil,
              "aggregates": nil,
              "filters": nil,
              "sort": nil,
              "computed-columns": nil,
              "plugin_config": {
                "realValues": [
                  "column_1",
                  "height",
                  nil,
                  nil,
                  "birth_state",
                  "birth_city"
                ]
              }
            },
            query_id: query.id,
            dataset_id: dataset.id
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
            refute_equal active_visualizations_count, response_data["data"].count
            assert_equal open_active_visualizations_count, response_data["data"].count
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

            refute_equal active_visualizations_count + 1, parsed_csv.count
            assert_equal open_active_visualizations_count + 1, parsed_csv.count
            assert_equal %w(id name privacy_status spec sql query_id dataset_id user_id), parsed_csv.first

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
            assert_nil sheet[open_active_visualizations_count + 1]
            assert_equal %w(id name privacy_status spec sql query_id dataset_id user_id), sheet[0].cells.map(&:value)
            values = (1..open_active_visualizations_count).map do |row_number|
              sheet[row_number].cells.map { |cell| cell.value.to_s }
            end
            assert_includes values, array_data(open_visualization).map(&:to_s)
            refute_includes values, array_data(closed_visualization).map(&:to_s)
          end
        end

        # GET /api/v1/data/visualizations.json?dataset_id=1
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

        def test_closed_visualizations_visibility
          with(site: site) do
            # Not logged in users can't see closed visualizations
            visualizations_names = []

            # Unfiltered
            get gobierto_data_api_v1_visualizations_path, as: :json
            response.parsed_body["data"].each { |item| visualizations_names << item.dig("attributes", "name") }

            # Filtered by dataset
            get gobierto_data_api_v1_visualizations_path(filter: { dataset_id: dataset.id }), as: :json
            response.parsed_body["data"].each { |item| visualizations_names << item.dig("attributes", "name") }

            # Filtered by user and dataset
            get gobierto_data_api_v1_visualizations_path(filter: { user_id: user.id, dataset_id: dataset.id }), as: :json
            response.parsed_body["data"].each { |item| visualizations_names << item.dig("attributes", "name") }

            refute_includes visualizations_names, closed_visualization.name
            refute_includes visualizations_names, other_user_closed_visualization.name

            # Logged in users can see owned closed visualizations compatible
            # with the filter

            # Unfiltered
            get gobierto_data_api_v1_visualizations_path, headers: { Authorization: user_token }, as: :json
            visualizations_names = response.parsed_body["data"].map { |item| item.dig("attributes", "name") }
            assert_includes visualizations_names, closed_visualization.name
            refute_includes visualizations_names, other_user_closed_visualization.name

            # Filtered by dataset
            get gobierto_data_api_v1_visualizations_path(filter: { dataset_id: other_dataset.id }), headers: { Authorization: user_token }, as: :json
            visualizations_names = response.parsed_body["data"].map { |item| item.dig("attributes", "name") }
            assert_includes visualizations_names, closed_visualization.name
            refute_includes visualizations_names, other_user_closed_visualization.name

            # Filtered by user and dataset
            get gobierto_data_api_v1_visualizations_path(filter: { user_id: user.id, dataset_id: other_dataset.id }), headers: { Authorization: user_token }, as: :json
            visualizations_names = response.parsed_body["data"].map { |item| item.dig("attributes", "name") }

            assert_includes visualizations_names, closed_visualization.name
            refute_includes visualizations_names, other_user_closed_visualization.name

            # Filtered by other user and dataset
            get gobierto_data_api_v1_visualizations_path(filter: { user_id: other_user.id, dataset_id: other_dataset.id }), headers: { Authorization: user_token }, as: :json
            visualizations_names = response.parsed_body["data"].map { |item| item.dig("attributes", "name") }

            refute_includes visualizations_names, closed_visualization.name
            refute_includes visualizations_names, other_user_closed_visualization.name
          end
        end

        # GET /api/v1/data/visualizations.json?query_id=1
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

        # GET /api/v1/data/visualizations.json?user_id=1
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

        # GET /api/v1/data/visualizations.json?user_id=1
        def test_index_filtered_by_user_with_different_user_token
          with(site: site) do
            get gobierto_data_api_v1_visualizations_path(filter: { user_id: user.id }), headers: { Authorization: other_user_token }, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            visualizations_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            assert_includes visualizations_names, user_visualization.name
            refute_includes visualizations_names, closed_visualization.name
            assert_includes visualizations_names, other_dataset_visualization.name
          end
        end

        # GET /api/v1/data/visualizations.json?user_id=1
        def test_index_filtered_by_user_with_same_user_token
          with(site: site) do
            get gobierto_data_api_v1_visualizations_path(filter: { user_id: user.id }), headers: { Authorization: user_token }, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            visualizations_names = response_data["data"].map { |item| item.dig("attributes", "name") }
            assert_includes visualizations_names, user_visualization.name
            assert_includes visualizations_names, closed_visualization.name
            assert_includes visualizations_names, other_dataset_visualization.name
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
        def test_create_without_token
          with(site: site) do
            assert_no_difference "GobiertoData::Visualization.count" do
              post gobierto_data_api_v1_visualizations_path, params: valid_params

              assert_response :unauthorized
            end
          end
        end

        # POST /api/v1/data/visualizations
        def test_create_with_invalid_token
          with(site: site) do
            assert_no_difference "GobiertoData::Visualization.count" do
              post gobierto_data_api_v1_visualizations_path, headers: { Authorization: "Bearer wadus" }, params: valid_params

              assert_response :unauthorized
            end
          end
        end

        # POST /api/v1/data/visualizations
        def test_create
          with(site: site) do
            assert_difference "GobiertoData::Visualization.count", 1 do
              post gobierto_data_api_v1_visualizations_path, headers: { Authorization: user_token }, params: valid_params, as: :json

              assert_response :created
              response_data = response.parsed_body

              new_visualization = Visualization.last

              assert_equal user, new_visualization.user

              # data
              assert response_data.has_key? "data"
              resource_data = response_data["data"]
              assert_equal resource_data["id"], new_visualization.id.to_s

              # attributes
              attributes = attributes_data(new_visualization)
              %w(name_translations privacy_status spec sql query_id dataset_id).each do |attribute|
                assert resource_data["attributes"].has_key? attribute
                assert_equal attributes[attribute], resource_data["attributes"][attribute]
              end
              assert_equal user.id, resource_data["attributes"]["user_id"]

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

        def test_create_with_query_and_blank_dataset
          with(site: site) do
            assert_difference "GobiertoData::Visualization.count", 1 do
              post gobierto_data_api_v1_visualizations_path, headers: { Authorization: user_token }, params: valid_params(except: [:dataset_id]), as: :json

              assert_response :created
              response_data = response.parsed_body

              new_visualization = Visualization.last

              assert_equal user, new_visualization.user

              # data
              assert response_data.has_key? "data"
              resource_data = response_data["data"]
              assert_equal resource_data["id"], new_visualization.id.to_s

              # attributes
              attributes = attributes_data(new_visualization)
              %w(name_translations privacy_status spec sql query_id dataset_id).each do |attribute|
                assert resource_data["attributes"].has_key? attribute
                assert_equal attributes[attribute], resource_data["attributes"][attribute]
              end
              assert_equal user.id, resource_data["attributes"]["user_id"]

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

        def test_create_with_dataset_and_blank_query
          with(site: site) do
            assert_difference "GobiertoData::Visualization.count", 1 do
              post gobierto_data_api_v1_visualizations_path, headers: { Authorization: user_token }, params: valid_params(except: [:query_id]), as: :json

              assert_response :created
              response_data = response.parsed_body

              new_visualization = Visualization.last

              assert_equal user, new_visualization.user

              # data
              assert response_data.has_key? "data"
              resource_data = response_data["data"]
              assert_equal resource_data["id"], new_visualization.id.to_s

              # attributes
              attributes = attributes_data(new_visualization)

              assert_nil resource_data["attributes"]["query_id"]
              %w(name_translations privacy_status spec sql dataset_id).each do |attribute|
                assert resource_data["attributes"].has_key? attribute
                assert_equal attributes[attribute], resource_data["attributes"][attribute]
              end
              assert_equal user.id, resource_data["attributes"]["user_id"]

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

        def test_create_failure_with_blank_dataset_and_query
          with(site: site) do
            assert_no_difference "GobiertoData::Visualization.count" do
              post gobierto_data_api_v1_visualizations_path, headers: { Authorization: user_token }, params: valid_params(except: [:query_id, :dataset_id]), as: :json

              assert_response :unprocessable_entity
              response_data = response.parsed_body

              assert response_data.has_key? "errors"
            end
          end
        end

        # POST /api/v1/data/visualizations
        def test_create_invalid_params
          with(site: site) do
            post gobierto_data_api_v1_visualizations_path, headers: { Authorization: user_token }, params: {}, as: :json

            assert_response :unprocessable_entity
            response_data = response.parsed_body

            assert response_data.has_key? "errors"
          end
        end

        # PUT /api/v1/data/visualizations/1
        def test_update_without_token
          with(site: site) do
            put gobierto_data_api_v1_visualization_path(visualization), params: valid_params, as: :json

            assert_response :unauthorized
          end
        end

        # PUT /api/v1/data/visualizations/1
        def test_update_with_invalid_token
          with(site: site) do
            put gobierto_data_api_v1_visualization_path(visualization), headers: { Authorization: "Bearer wadus" }, params: valid_params, as: :json

            assert_response :unauthorized
          end
        end

        # PUT /api/v1/data/visualizations/1
        def test_update_with_other_user_token
          with(site: site) do
            put gobierto_data_api_v1_visualization_path(visualization), headers: { Authorization: other_user_token }, params: valid_params, as: :json

            assert_response :unauthorized
          end
        end

        # PUT /api/v1/data/visualizations/1
        def test_update
          with(site: site) do
            assert_no_difference "GobiertoData::Visualization.count" do
              put gobierto_data_api_v1_visualization_path(visualization), headers: { Authorization: user_token }, params: valid_params, as: :json

              assert_response :success
              response_data = response.parsed_body

              # data
              assert response_data.has_key? "data"
              resource_data = response_data["data"]
              assert_equal resource_data["id"], visualization.id.to_s

              # attributes
              attributes = valid_params[:data][:attributes].with_indifferent_access
              %w(name_translations privacy_status spec sql query_id).each do |attribute|
                assert resource_data["attributes"].has_key? attribute
                assert_equal attributes[attribute], resource_data["attributes"][attribute]
              end
              assert_equal user.id, resource_data["attributes"]["user_id"]

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

        # PUT /api/v1/data/visualizations/1
        def test_update_invalid_params
          with(site: site) do
            put gobierto_data_api_v1_visualization_path(visualization), headers: { Authorization: user_token }, params: {}, as: :json

            assert_response :unprocessable_entity
            response_data = response.parsed_body

            assert response_data.has_key? "errors"
          end
        end

        # DELETE /api/v1/data/visualizations/1
        def test_delete_without_token
          with(site: site) do
            assert_no_difference "GobiertoData::Visualization.count" do
              delete gobierto_data_api_v1_visualization_path(visualization), as: :json

              assert_response :unauthorized
            end
          end
        end

        # DELETE /api/v1/data/visualizations/1
        def test_delete_with_invalid_token
          with(site: site) do
            assert_no_difference "GobiertoData::Visualization.count" do
              delete gobierto_data_api_v1_visualization_path(visualization), headers: { Authorization: "Bearer wadus" }, as: :json

              assert_response :unauthorized
            end
          end
        end

        # DELETE /api/v1/data/visualizations/1
        def test_delete_with_other_user_token
          with(site: site) do
            assert_no_difference "GobiertoData::Visualization.count" do
              delete gobierto_data_api_v1_visualization_path(visualization), headers: { Authorization: other_user_token }, as: :json

              assert_response :unauthorized
            end
          end
        end

        # DELETE /api/v1/data/visualizations/1
        def test_delete
          id = visualization.id
          assert_difference "GobiertoData::Visualization.count", -1 do
            with(site: site) do
              delete gobierto_data_api_v1_visualization_path(id), headers: { Authorization: user_token }, as: :json

              assert_response :no_content

              assert_nil Visualization.find_by(id: id)
            end
          end
        end

        # Sortable API concern

        # GET /api/v1/data/visualizations?order
        def test_order_without_params_is_ignored
          with(site: site) do
            get gobierto_data_api_v1_visualizations_path
            unordered_response_data = response.parsed_body

            get gobierto_data_api_v1_visualizations_path(order: "")
            assert_response :success

            assert_equal unordered_response_data, response.parsed_body
          end
        end

        def test_order_with_not_configured_attribute_is_ignored
          with(site: site) do
            get gobierto_data_api_v1_visualizations_path
            unordered_response_data = response.parsed_body

            get gobierto_data_api_v1_visualizations_path(order: { id: "desc" })
            assert_response :success

            assert_equal unordered_response_data, response.parsed_body
          end
        end

        def test_order_with_configured_attribute_but_invalid_sorting_value_is_replaced_with_asc
          with(site: site) do
            get gobierto_data_api_v1_visualizations_path(order: { created_at: "asc" })
            ordered_response_data = response.parsed_body

            get gobierto_data_api_v1_visualizations_path(order: { created_at: "wadus" })
            assert_response :success

            assert_equal ordered_response_data, response.parsed_body
          end
        end

        def test_order_with_configured_attribute_and_valid_sorting_criteria
          with(site: site) do
            get gobierto_data_api_v1_visualizations_path
            unordered_response_data = response.parsed_body

            get gobierto_data_api_v1_visualizations_path(order: { created_at: "desc" })
            assert_response :success

            response_data = response.parsed_body
            refute_equal unordered_response_data, response_data
            assert_equal unordered_response_data["data"].count, response_data["data"].count
            assert_equal latest_visualization.id, response_data["data"].first.dig("id").to_i
          end
        end
      end
    end
  end
end
