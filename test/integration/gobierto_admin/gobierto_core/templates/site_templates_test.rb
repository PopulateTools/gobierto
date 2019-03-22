# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCore
    class SiteTemplatesTest < ActionDispatch::IntegrationTest

      include PermissionHelpers

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def regular_admin
        @regular_admin ||= gobierto_admin_admins(:tony)
      end

      def site
        @site ||= sites(:madrid)
      end

      def setup
        grant_templates_permission(regular_admin, site: site)
        super
      end

      def test_create_when_unauthorized
        with_signed_in_admin(regular_admin) do
          with_current_site(site) do
            visit admin_root_path

            click_link "Templates"

            revoke_templates_permission(regular_admin)

            click_button "Save"

            assert has_content? "You are not authorized to perform this action"
            assert_equal admin_root_path, current_path
          end
        end
      end

      def test_edit_when_unauthorized
        with_signed_in_admin(regular_admin) do
          with_current_site(site) do
            visit admin_root_path

            click_link "Templates"

            revoke_templates_permission(regular_admin)

            click_link "application"

            assert has_content? "You are not authorized to perform this action"
            assert_equal admin_root_path, current_path
          end
        end
      end

      def test_destroy_when_unauthorized
        with_signed_in_admin(regular_admin) do
          with_current_site(site) do
            visit admin_root_path

            click_link "Templates"

            revoke_templates_permission(regular_admin)

            click_button "Reset"

            assert has_content? "You are not authorized to perform this action"
            assert_equal admin_root_path, current_path
          end
        end
      end

    end
  end
end
