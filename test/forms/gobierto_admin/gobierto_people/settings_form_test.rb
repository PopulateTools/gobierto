# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class SettingsFormTest < ActiveSupport::TestCase

      def site
        @site ||= sites(:madrid)
      end

      def settings_attributes
        @settings_attributes ||= {
          site_id: site.id,
          home_text_en: 'English text',
          submodules_enabled: ['blogs']
        }
      end

      def valid_settings_form
        @valid_settings_form ||= SettingsForm.new(settings_attributes)
      end

      def test_save_with_valid_attributes
        assert valid_settings_form.save
        assert_equal "English text", valid_settings_form.gobierto_module_settings.home_text_en
      end

      def test_saving_form_encrypts_credentials
        settings_form = SettingsForm.new(settings_attributes.merge(
          ibm_notes_usr: 'plain-text-usr',
          ibm_notes_pwd: 'plain-text-pwd'
        ))

        assert settings_form.save

        assert_equal 'plain-text-usr', ::SecretAttribute.decrypt(site.gobierto_people_settings.ibm_notes_usr)
        assert_equal 'plain-text-pwd', ::SecretAttribute.decrypt(site.gobierto_people_settings.ibm_notes_pwd)
      end

      def test_html_dummy_credentials
        persisted_settings_form = SettingsForm.new(site_id: site.id)

        # when credentials are set, the placeholder is returned
        assert_equal SettingsForm::ENCRYPTED_SETTING_PLACEHOLDER, persisted_settings_form.dummy_ibm_notes_usr
        assert_equal SettingsForm::ENCRYPTED_SETTING_PLACEHOLDER, persisted_settings_form.dummy_ibm_notes_pwd

        gp_settings = site.gobierto_people_settings
        gp_settings.ibm_notes_usr = ''
        gp_settings.ibm_notes_pwd = nil
        gp_settings.save!

        persisted_settings_form = SettingsForm.new(site_id: site.id)

        # when credentials are not set, the original value is returned
        assert_equal '', persisted_settings_form.dummy_ibm_notes_usr
        assert_nil persisted_settings_form.dummy_ibm_notes_pwd
      end

    end
  end
end
