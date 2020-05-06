# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoDashboards
    module Configuration
      module Settings
        class UpdateSettingsTest < ActionDispatch::IntegrationTest

          def setup
            super
            @path = edit_admin_dashboards_configuration_settings_path
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

          def valid_config
            @valid_config ||= {
              dashboards: {
                contracts: {
                  enabled: false,
                  data_urls: {
                    endpoint: 'http://wadus.dev'
                  }
                }
              }
            }.to_json
          end

          def invalid_config
            @invalid_config ||= { dashboards: {foo: :bar} }.to_json
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

          def test_update_dashboards_config_invalid_json
            with(site: site, admin: admin) do
              visit @path

              fill_in "gobierto_dashboards_settings_dashboards_config", with: "wadus wadus"

              click_button "Update"

              assert has_alert?("The configuration does not have a valid JSON format")
            end
          end

          def test_update_dashboards_config_invalid_config
            with(site: site, admin: admin) do
              visit @path

              fill_in "gobierto_dashboards_settings_dashboards_config", with: invalid_config

              click_button "Update"

              assert has_alert?("The configuration does not have valid values")
            end
          end

          def test_update_dashboards_config_valid_config
            with(site: site, admin: admin) do
              visit @path

              assert has_field? "gobierto_dashboards_settings_dashboards_config", with: ''

              fill_in "gobierto_dashboards_settings_dashboards_config", with: valid_config

              click_button "Update"

              assert has_message?("Configuration stored successfully")
            end
          end

        end
      end
    end
  end
end
