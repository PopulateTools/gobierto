# frozen_string_literal: true

require "test_helper"
require "support/calendar_integration_helpers"

module GobiertoAdmin
  module GobiertoPeople
    class SettingsUpdateTest < ActionDispatch::IntegrationTest

      include ::CalendarIntegrationHelpers

      def setup
        super
        @path = edit_admin_people_configuration_settings_path
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_setting_update
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "#edit_gobierto_people_settings" do
              fill_in "gobierto_people_settings_home_text_es", with: "Texto Spanish"
              fill_in "gobierto_people_settings_home_text_en", with: "Texto English"
              check "Agendas"
              check "Blogs"
              uncheck "Statements"

              click_button "Update"
            end

            assert has_message?("Settings updated successfully")

            within "#edit_gobierto_people_settings" do
              assert has_field?("gobierto_people_settings_home_text_es", with: "Texto Spanish")
              assert has_field?("gobierto_people_settings_home_text_en", with: "Texto English")
              assert has_checked_field?("Agendas")
              assert has_checked_field?("Blogs")
              refute has_checked_field?("Statements")
            end
          end
        end
      end

      def test_calendar_integration_settings_update
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            ## clear IBM Notes calendar integration
            select "", from: "gobierto_people_settings_calendar_integration"
            fill_in "gobierto_people_settings_ibm_notes_usr", with: ''
            fill_in "gobierto_people_settings_ibm_notes_pwd", with: ''

            click_button "Update"

            assert has_message?("Settings updated successfully")

            madrid = Site.find(site.id)

            # assert encrypted credentials were destroyed
            assert_nil madrid.gobierto_people_settings.ibm_notes_usr
            assert_nil madrid.gobierto_people_settings.ibm_notes_pwd
            assert_nil find_field('gobierto_people_settings_ibm_notes_usr').value
            assert_nil find_field('gobierto_people_settings_ibm_notes_pwd').value

            ## setup IBM Notes calendar integration
            select "IBM Notes", from: "gobierto_people_settings_calendar_integration"
            fill_in "gobierto_people_settings_ibm_notes_usr", with: "IBM Notes user"
            fill_in "gobierto_people_settings_ibm_notes_pwd", with: "IBM Notes password"

            click_button "Update"

            assert has_message?("Settings updated successfully")

            # assert encrypted credentials were stored in the DB
            assert_equal 'IBM Notes user', ::SecretAttribute.decrypt(site.gobierto_people_settings.ibm_notes_usr)
            assert_equal 'IBM Notes password', ::SecretAttribute.decrypt(site.gobierto_people_settings.ibm_notes_pwd)

            # assert dummy placeholders are displayed in the UI
            assert has_field?("gobierto_people_settings_ibm_notes_usr", with: SettingsForm::ENCRYPTED_SETTING_PLACEHOLDER)
            assert has_field?("gobierto_people_settings_ibm_notes_pwd", with: SettingsForm::ENCRYPTED_SETTING_PLACEHOLDER)
          end
        end
      end

      def test_prohibit_saving_erroneous_calendar_configuration_settings
        remove_ibm_notes_calendar_integration(site)

        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            select "IBM Notes", from: "gobierto_people_settings_calendar_integration"

            click_button "Update"

            assert has_message?("An error occured while saving these settings")

            select "", from: "gobierto_people_settings_calendar_integration"
            fill_in "gobierto_people_settings_ibm_notes_usr", with: "IBM Notes user"
            fill_in "gobierto_people_settings_ibm_notes_pwd", with: "IBM Notes password"

            click_button "Update"

            assert has_message?("An error occured while saving these settings")
          end
        end
      end
    end
  end
end
