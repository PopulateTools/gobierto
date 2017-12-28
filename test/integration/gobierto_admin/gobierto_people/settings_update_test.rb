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

    end
  end
end
