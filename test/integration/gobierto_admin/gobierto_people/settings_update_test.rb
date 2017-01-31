require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class SettingsUpdateTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_people_configuration_settings_path
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def setting
        @setting ||= gobierto_people_settings(:home_text)
      end

      def test_setting_update
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "#edit_gobierto_people_setting_#{setting.id}" do
              fill_in "gobierto_people_setting_value", with: "New value"

              click_button "Update"
            end

            assert has_message?("Setting updated successfully")

            within "#edit_gobierto_people_setting_#{setting.id}" do
              assert has_field?("gobierto_people_setting_value", with: "New value")
            end
          end
        end
      end
    end
  end
end
