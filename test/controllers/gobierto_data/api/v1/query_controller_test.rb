# frozen_string_literal: true

require "test_helper"

module GobiertoData
  module Api
    module V1
      class QueryControllerTest < GobiertoControllerTest

        def site
          @site ||= sites(:madrid)
        end

        def site_with_module_disabled
          @site_with_module_disabled ||= sites(:santander)
        end

        def user
          @user ||= users(:dennis)
        end

        def users_count
          @users_count ||= User.count
        end

        def test_index
          with(site: site) do
            get gobierto_data_api_v1_root_path(sql: "SELECT COUNT(*) AS test_count FROM users"), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            assert_equal 1, response_data["data"].count
            assert_equal users_count, response_data["data"].first["test_count"]
          end
        end

        def test_index_csv_format
          with(site: site) do
            get gobierto_data_api_v1_root_path(sql: "SELECT id, name FROM users", format: :csv), as: :csv

            assert_response :success

            response_data = response.parsed_body
            parsed_csv = CSV.parse(response_data)

            assert_match(/\Aid,name\n/, response_data)
            assert_equal users_count + 1, parsed_csv.count
            assert_equal %w(id name), parsed_csv.first
            assert_includes parsed_csv, [user.id.to_s, user.name]
          end
        end

        def test_index_csv_format_separator
          with(site: site) do
            get gobierto_data_api_v1_root_path(sql: "SELECT id, name FROM users", csv_separator: "semicolon", format: :csv), as: :csv

            assert_response :success

            response_data = response.parsed_body
            parsed_csv = CSV.parse(response_data, col_sep: ";")

            assert_match(/\Aid\;name\n/, response_data)
            assert_equal users_count + 1, parsed_csv.count
            assert_equal %w(id name), parsed_csv.first
            assert_includes parsed_csv, [user.id.to_s, user.name]
          end
        end

        def test_index_xlsx_format
          with(site: site) do
            get gobierto_data_api_v1_root_path(sql: "SELECT id, name FROM users", format: :xlsx), as: :xlsx

            assert_response :success

            parsed_xlsx = RubyXL::Parser.parse_buffer response.parsed_body

            assert_equal 1, parsed_xlsx.worksheets.count
            sheet = parsed_xlsx.worksheets.first
            assert_nil sheet[users_count + 1]
            assert_equal %w(id name), sheet[0].cells.map(&:value)
            values = (1..users_count).map do |row_number|
              sheet[row_number].cells.map(&:value)
            end
            assert_includes values, [user.id, user.name]
          end
        end

        def test_index_with_module_disabled
          with(site: site_with_module_disabled) do
            get gobierto_data_api_v1_root_path(sql: "SELECT COUNT(*) AS test_count FROM users"), as: :json

            assert_response :forbidden
          end
        end

        def test_index_with_invalid_query
          with(site: site) do
            get gobierto_data_api_v1_root_path(sql: "SELECT COUNT(*) AS test_count FROM not_existing_table"), as: :json

            assert_response :bad_request

            response_data = response.parsed_body

            assert response_data.has_key? "errors"
            assert_equal 1, response_data["errors"].count
            assert_match(/UndefinedTable/, response_data["errors"].first["sql"])
          end
        end

      end
    end
  end
end
