# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoDashboards
    class SettingsFormTest < ActiveSupport::TestCase

      def site
        @site ||= sites(:madrid)
      end

      # Valid settings
      def valid_dashboard_config
        ::GobiertoDashboards.default_dashboards_configuration_settings
      end

      def valid_settings_attributes
        {
          site_id: site.id,
          dashboards_config: valid_dashboard_config
        }
      end

      def valid_settings_form
        @valid_settings_form ||= SettingsForm.new(valid_settings_attributes)
      end

      # Invalid main key settings
      def invalid_main_key_dashboard_config
        {
          "paneles": {
            "contracts": {
              "enabled": false,
              "data_urls": {
                "endpoint": ""
              }
            }
          }
        }.to_json
      end

      def invalid_main_key_settings_attributes
        {
          site_id: site.id,
          dashboards_config: invalid_main_key_dashboard_config
        }
      end

      def invalid_main_key_settings_form
        @invalid_main_key_settings_form ||= SettingsForm.new(invalid_main_key_settings_attributes)
      end

      # Invalid dashboard names settings
      def invalid_dashboards_names_dashboard_config
        {
          "dashboards": {
            "contratos": {
              "enabled": false,
              "data_urls": {
                "endpoint": ""
              }
            }
          }
        }.to_json
      end

      def invalid_dashboards_names_settings_attributes
        {
          site_id: site.id,
          dashboards_config: invalid_dashboards_names_dashboard_config
        }
      end

      def invalid_dashboards_names_settings_form
        @invalid_dashboards_names_settings_form ||= SettingsForm.new(invalid_dashboards_names_settings_attributes)
      end

      # Invalid format settings
      def invalid_format_dashboard_config
        <<JSON
        {
          "dashboards" => {
            "contracts": {
              "enabled": false,
              "data_urls": {
                "endpoint": ""
              }
            }
          }
        }
JSON
      end

      def invalid_format_settings_attributes
        {
          site_id: site.id,
          dashboards_config: invalid_format_dashboard_config
        }
      end

      def invalid_format_settings_form
        @invalid_format_settings_form ||= SettingsForm.new(invalid_format_settings_attributes)
      end

      # Tests
      def test_save_with_valid_attributes
        assert valid_settings_form.save
        assert valid_settings_form.persisted?

        assert valid_settings_form.gobierto_module_settings.dashboards_config['dashboards'].present?
        assert valid_settings_form.gobierto_module_settings.dashboards_config.dig('dashboards', 'contracts').present?
        assert valid_settings_form.gobierto_module_settings.dashboards_config.dig('dashboards', 'tenders').present?
      end

      def test_does_not_save_with_invalid_main_key
        refute invalid_main_key_settings_form.save
        refute invalid_main_key_settings_form.persisted?
      end

      def test_does_not_save_with_invalid_dashboard_names
        refute invalid_dashboards_names_settings_form.save
        refute invalid_dashboards_names_settings_form.persisted?
      end

      def test_does_not_save_with_invalid_format
        refute invalid_format_settings_form.save
        refute invalid_format_settings_form.persisted?
      end

    end
  end
end
