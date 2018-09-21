# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCms
    class CreatePageTest < ActionDispatch::IntegrationTest
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

      def collection
        @collection ||= gobierto_common_collections(:news)
      end

      def test_create_page_errors
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "tr#collection-item-#{collection.id}" do
                click_link "News"
              end

              assert has_selector?("h1", text: "CMS")

              click_link "New"
              assert has_selector?("h1", text: "Sport city")
              click_button "Create"
              assert has_alert?("Title can't be blank")
              assert has_alert?("Body can't be blank")
            end
          end
        end
      end

      def test_create_page
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "tr#collection-item-#{collection.id}" do
                click_link "News"
              end

              assert has_selector?("h1", text: "CMS")

              click_link "New"
              assert has_selector?("h1", text: "Sport city")

              fill_in "page_title_translations_en", with: "My page"
              find("#page_body_translations_en", visible: false).set("The content of the page")
              fill_in "page_slug", with: "new-page"
              fill_in "page_published_on", with: "2017-01-01 00:00"

              click_link "ES"
              fill_in "page_title_translations_es", with: "Mi página"
              find("#page_body_translations_es", visible: false).set("Contenido de la página")

              click_button "Create"

              assert has_message?("Page created successfully")
              assert has_field?("page_slug", with: "new-page")
              assert has_field?("page_published_on", with: "2017-01-01 00:00:00 +0100")

              assert_equal(
                "The content of the page",
                find("#page_body_translations_en", visible: false).value
              )

              click_link "ES"

              assert_equal(
                "Contenido de la página",
                find("#page_body_translations_es", visible: false).value
              )
            end
          end
        end
      end
    end
  end
end
