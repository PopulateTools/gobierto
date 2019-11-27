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

        def test_index
          with(site: site) do
            get gobierto_data_api_v1_root_path(sql: "SELECT COUNT(*) AS test_count FROM users"), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            assert_equal 1, response_data["data"].count
            assert_equal 7, response_data["data"].first["test_count"]
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
