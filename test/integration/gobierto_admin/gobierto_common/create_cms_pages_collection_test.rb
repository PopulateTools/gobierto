# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    class CreateCmsPagesCollectionTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_cms_pages_path
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_create_collection_errors
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "#new-page" do
                click_link "New"
              end

              click_button "Create"

              assert has_alert?("Title can't be blank")
            end
          end
        end
      end

      def test_create_collection
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "#new-page" do
                click_link "New"
              end

              fill_in "collection_title_translations_en", with: "My collection"
              fill_in "collection_slug", with: "my-collection"
              find("select#collection_container_global_id").find("option[value='#{site.to_global_id}']").select_option
              find("select#collection_item_type").find("option[value='GobiertoCms::Page']").select_option

              click_link "ES"
              fill_in "collection_title_translations_es", with: "Mi colección"

              click_button "Create"

              assert has_message?("Collection was successfully created.")

              assert has_selector?("h1", text: "My collection")

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
