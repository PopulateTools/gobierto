# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoObservatory
    class SettingsFormTest < ActiveSupport::TestCase

      def site
        @site ||= sites(:madrid)
      end

      # Valid settings
      def valid_observatory_config
        ::GobiertoObservatory.default_observatory_configuration_settings
      end

      def valid_settings_attributes
        {
          site_id: site.id,
          observatory_config: valid_observatory_config
        }
      end

      def valid_settings_form
        @valid_settings_form ||= SettingsForm.new(valid_settings_attributes)
      end

      # Valid empty settings
      def valid_empty_observatory_config
        { "observatory": {} }.to_json
      end

      def valid_empty_settings_attributes
        {
          site_id: site.id,
          observatory_config: valid_empty_observatory_config
        }
      end

      def valid_empty_settings_form
        @valid_empty_settings_form ||= SettingsForm.new(valid_empty_settings_attributes)
      end

      # Invalid main key settings (it should be 'observatory' instead of 'wadus')
      def invalid_main_key_observatory_config
        {
          "wadus": {
            "map": {
              "enabled": false,
            }
          }
        }.to_json
      end

      def invalid_main_key_settings_attributes
        {
          site_id: site.id,
          observatory_config: invalid_main_key_observatory_config
        }
      end

      def invalid_main_key_settings_form
        @invalid_main_key_settings_form ||= SettingsForm.new(invalid_main_key_settings_attributes)
      end

      # Invalid observatory names settings (it should have any value from GobiertoAdmin::GobiertoObservatory::SettingsForm::VALID_DASHBOARDS_NAMES)
      def invalid_observatory_names_observatory_config
        {
          "observatory": {
            "wadus": {
              "enabled": false,
              "data_urls": {
                "endpoint": ""
              }
            }
          }
        }.to_json
      end

      def invalid_observatory_names_settings_attributes
        {
          site_id: site.id,
          observatory_config: invalid_observatory_names_observatory_config
        }
      end

      def invalid_observatory_names_settings_form
        @invalid_observatory_names_settings_form ||= SettingsForm.new(invalid_observatory_names_settings_attributes)
      end

      # Invalid format settings
      def invalid_format_observatory_config
        <<JSON
        {
          "observatory" => {
            "map": {
              "enabled": false
              }
            }
          }
        }
JSON
      end

      def invalid_format_settings_attributes
        {
          site_id: site.id,
          observatory_config: invalid_format_observatory_config
        }
      end

      def invalid_format_settings_form
        @invalid_format_settings_form ||= SettingsForm.new(invalid_format_settings_attributes)
      end

      # Tests
      def test_save_with_valid_attributes
        assert valid_settings_form.save
        assert valid_settings_form.persisted?

        assert valid_settings_form.gobierto_module_settings.observatory_config['observatory'].present?
        assert valid_settings_form.gobierto_module_settings.observatory_config.dig('observatory', 'map').present?
      end

      def test_save_with_valid_empty_attributes
        assert valid_empty_settings_form.save
        assert valid_empty_settings_form.persisted?

        assert valid_empty_settings_form.gobierto_module_settings.observatory_config.has_key?('observatory')
        assert valid_empty_settings_form.gobierto_module_settings.observatory_config.dig('observatory', 'map').blank?
      end

      def test_does_not_save_with_invalid_main_key
        refute invalid_main_key_settings_form.save
        refute invalid_main_key_settings_form.persisted?
      end

      def test_does_not_save_with_invalid_observatory_names
        refute invalid_observatory_names_settings_form.save
        refute invalid_observatory_names_settings_form.persisted?
      end

      def test_does_not_save_with_invalid_format
        refute invalid_format_settings_form.save
        refute invalid_format_settings_form.persisted?
      end

    end
  end
end
