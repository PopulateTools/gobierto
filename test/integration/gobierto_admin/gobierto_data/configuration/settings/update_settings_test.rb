# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoData
    module Configuration
      module Settings
        class UpdateSettgingsTest < ActionDispatch::IntegrationTest

          def setup
            super
            @path = edit_admin_data_configuration_settings_path
          end

          def admin
            @admin ||= gobierto_admin_admins(:nick)
          end

          def unauthorized_regular_admin
            @unauthorized_regular_admin ||= gobierto_admin_admins(:steve)
          end

          def authorized_regular_admin
            @authorized_regular_admin ||= gobierto_admin_admins(:tony)
          end

          def valid_connection_params
            @valid_connection_params ||= site.gobierto_data_settings.db_config.to_json
          end

          def invalid_connection_params
            @invalid_connection_params ||= { foo: :bar }.to_json
          end

          def site
            @site ||= sites(:madrid)
          end

          def test_regular_admin_permissions_not_authorized
            with(site: site, admin: unauthorized_regular_admin) do
              visit @path
              assert has_content?("You are not authorized to perform this action")
              assert_equal edit_admin_admin_settings_path, current_path
            end
          end

          def test_regular_admin_permissions_authorized
            with(site: site, admin: authorized_regular_admin) do
              visit @path
              assert has_no_content?("You are not authorized to perform this action")
              assert_equal @path, current_path
            end
          end

          def test_update_db_config_invalid_json
            with(site: site, admin: admin) do
              visit @path

              fill_in "gobierto_data_settings_db_config", with: "wadus wadus"

              click_button "Update"

              assert has_alert?("The configuration does not have a valid JSON format")
            end
          end

          def test_update_db_config_invalid_connection_params
            with(site: site, admin: admin) do
              visit @path

              fill_in "gobierto_data_settings_db_config", with: invalid_connection_params

              click_button "Update"

              assert has_alert?("Unable to connect using configuration data")
            end
          end

          def test_update_db_config_valid_connection_params
            site.gobierto_data_settings.destroy

            with(site: site, admin: admin) do
              visit @path

              assert has_field? "gobierto_data_settings_db_config", with: ""

              fill_in "gobierto_data_settings_db_config", with: valid_connection_params

              click_button "Update"

              assert has_message?("Configuration stored successfully")
            end
          end

          def test_api_settings_defaults
            site.gobierto_data_settings.destroy

            with(site: site, admin: admin) do
              visit @path

              assert has_checked_field? "gobierto_data_settings_api_settings_exposed_in_public_api"
              assert has_field? "gobierto_data_settings_api_settings_max_dataset_size_for_queries", with: 0
              assert has_field? "gobierto_data_settings_api_settings_default_limit_for_queries", with: 50
            end
          end

          def test_api_settings_update
            with(site: site, admin: admin) do
              visit @path

              fill_in "gobierto_data_settings_api_settings_max_dataset_size_for_queries", with: 100
              fill_in "gobierto_data_settings_api_settings_default_limit_for_queries", with: 250
              click_button "Update"

              visit gobierto_common_api_v1_configuration_path("gobierto_data")

              response = JSON.parse(page.text)
              assert_equal 100, response.dig("api_settings", "max_dataset_size_for_queries")
              assert_equal 250, response.dig("api_settings", "default_limit_for_queries")
            end
          end
        end
      end
    end
  end
end
