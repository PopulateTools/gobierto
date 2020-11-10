# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoVisualizations
    class SettingsFormTest < ActiveSupport::TestCase

      def site
        @site ||= sites(:madrid)
      end

      # Valid settings
      def valid_visualization_config
        ::GobiertoVisualizations.default_visualizations_configuration_settings
      end

      def valid_settings_attributes
        {
          site_id: site.id,
          visualizations_config: valid_visualization_config
        }
      end

      def valid_settings_form
        @valid_settings_form ||= SettingsForm.new(valid_settings_attributes)
      end

      # Valid empty settings
      def valid_empty_visualization_config
        { "visualizations": {} }.to_json
      end

      def valid_empty_settings_attributes
        {
          site_id: site.id,
          visualizations_config: valid_empty_visualization_config
        }
      end

      def valid_empty_settings_form
        @valid_empty_settings_form ||= SettingsForm.new(valid_empty_settings_attributes)
      end

      # Invalid main key settings (it should be 'visualizations' instead of 'wadus')
      def invalid_main_key_visualization_config
        {
          "wadus": {
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
          visualizations_config: invalid_main_key_visualization_config
        }
      end

      def invalid_main_key_settings_form
        @invalid_main_key_settings_form ||= SettingsForm.new(invalid_main_key_settings_attributes)
      end

      # Invalid visualization names settings (it should have any value from GobiertoAdmin::GobiertoVisualizations::SettingsForm::VALID_DASHBOARDS_NAMES)
      def invalid_visualizations_names_visualization_config
        {
          "visualizations": {
            "wadus": {
              "enabled": false,
              "data_urls": {
                "endpoint": ""
              }
            }
          }
        }.to_json
      end

      def invalid_visualizations_names_settings_attributes
        {
          site_id: site.id,
          visualizations_config: invalid_visualizations_names_visualization_config
        }
      end

      def invalid_visualizations_names_settings_form
        @invalid_visualizations_names_settings_form ||= SettingsForm.new(invalid_visualizations_names_settings_attributes)
      end

      # Invalid format settings
      def invalid_format_visualization_config
        <<JSON
        {
          "visualizations" => {
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
          visualizations_config: invalid_format_visualization_config
        }
      end

      def invalid_format_settings_form
        @invalid_format_settings_form ||= SettingsForm.new(invalid_format_settings_attributes)
      end

      # Tests
      def test_save_with_valid_attributes
        assert valid_settings_form.save
        assert valid_settings_form.persisted?

        assert valid_settings_form.gobierto_module_settings.visualizations_config['visualizations'].present?
        assert valid_settings_form.gobierto_module_settings.visualizations_config.dig('visualizations', 'contracts').present?
        assert valid_settings_form.gobierto_module_settings.visualizations_config.dig('visualizations', 'subsidies').present?
      end

      def test_save_with_valid_empty_attributes
        assert valid_empty_settings_form.save
        assert valid_empty_settings_form.persisted?

        assert valid_empty_settings_form.gobierto_module_settings.visualizations_config.has_key?('visualizations')
        assert valid_empty_settings_form.gobierto_module_settings.visualizations_config.dig('visualizations', 'contracts').blank?
        assert valid_empty_settings_form.gobierto_module_settings.visualizations_config.dig('visualizations', 'subsidies').blank?
      end

      def test_does_not_save_with_invalid_main_key
        refute invalid_main_key_settings_form.save
        refute invalid_main_key_settings_form.persisted?
      end

      def test_does_not_save_with_invalid_visualization_names
        refute invalid_visualizations_names_settings_form.save
        refute invalid_visualizations_names_settings_form.persisted?
      end

      def test_does_not_save_with_invalid_format
        refute invalid_format_settings_form.save
        refute invalid_format_settings_form.persisted?
      end

    end
  end
end
