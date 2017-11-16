# frozen_string_literal: true

require "test_helper"
require "support/file_uploader_helpers"

module GobiertoAdmin
  module GobiertoCalendars
    class CollectionsTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_calendars_collections_path
      end

      def site
        @site ||= sites(:madrid)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def process
        @process ||= gobierto_participation_processes(:green_city_group)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def test_list_of_collections
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "table tbody" do
              assert has_content?("Richard calendar")
              assert has_content?("Nelson calendar")
            end
          end
        end
      end

      def test_create_collection
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              click_link "New"

              fill_in "collection_title_translations_en", with: "My collection"
              fill_in "collection_slug", with: "my-collection"
              find("select#collection_container_global_id").find("option[value='#{process.to_global_id}']").select_option
              find("select#collection_item_type").find("option[value='GobiertoCalendars::Event']").select_option

              click_link "ES"
              fill_in "collection_title_translations_es", with: "Mi colección"

              click_button "Create"

              assert has_message?("Collection was successfully created.")

              collection = site.collections.last
              activity = Activity.last
              assert_equal collection, activity.subject
              assert_equal admin, activity.author
              assert_equal site.id, activity.site_id
              assert_equal "gobierto_common.collection_created", activity.action
            end
          end
        end
      end
    end
  end
end
