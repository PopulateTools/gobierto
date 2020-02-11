# frozen_string_literal: true

require "test_helper"

module GobiertoCommon
  module Api
    module V1
      class ConfigurationControllerTest < GobiertoControllerTest

        def site
          @site ||= sites(:madrid)
        end

        def site_with_module_disabled
          @site_with_module_disabled ||= sites(:santander)
        end

        def test_show_with_module_disabled
          with(site: site_with_module_disabled) do
            get gobierto_common_api_v1_configuration_path(module_name: "gobierto-data"), as: :json

            assert_response :forbidden
          end
        end

        def test_show_with_not_existing_module
          with(site: site_with_module_disabled) do
            get gobierto_common_api_v1_configuration_path(module_name: "gobierto-wadus"), as: :json

            assert_response :forbidden
          end
        end

        def test_show
          with(site: site) do
            get gobierto_common_api_v1_configuration_path(module_name: "gobierto-data"), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "api_configuration"
            refute response_data.has_key? "db_config"
            refute response_data.has_key? "api_private_configuration"
          end
        end

      end
    end
  end
end
