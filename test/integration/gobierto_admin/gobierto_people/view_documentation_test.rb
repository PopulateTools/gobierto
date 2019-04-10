# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class ViewDocumentationTest < ActionDispatch::IntegrationTest

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

            assert has_link?("View documentation")
          end
        end
      end
    end
  end
end
