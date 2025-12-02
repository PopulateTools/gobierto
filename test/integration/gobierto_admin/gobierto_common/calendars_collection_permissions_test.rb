# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    class CalendarsCollectionPermissionsTest < ActionDispatch::IntegrationTest
      def setup
        super
        @collection = gobierto_common_collections(:richard_calendar)
        @path = admin_common_collection_path(@collection)
      end

      def admin
        @admin ||= gobierto_admin_admins(:tony)
      end

      def admin_group
        @admin_group ||= gobierto_admin_admin_groups(:madrid_group)
      end

      def site_madrid
        @site_madrid ||= sites(:madrid)
      end

      def test_permissions_not_authorized
        admin_group.permissions.destroy_all

        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site_madrid) do
              visit @path

              assert has_content? "You are not authorized to perform this action"
            end
          end
        end
      end

      def test_permissions_authorized
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site_madrid) do
              visit @path

              assert has_no_content? "You are not authorized to perform this action"
              assert has_content? "Richard Rider"
            end
          end
        end
      end
    end
  end
end
