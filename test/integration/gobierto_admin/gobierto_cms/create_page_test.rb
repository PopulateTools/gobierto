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

      def chosen_publication_date
        Time.zone.parse("2017-01-01 00:00")
      end

      def stubbed_current_time
        Time.zone.parse("2018-01-01 12:30:59 +0100")
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
        Timecop.freeze(stubbed_current_time)

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

              # ensure default date is set
              assert_equal stubbed_current_time.to_s, air_datepicker_field_value(:page_published_on)

              fill_in "page_title_translations_en", with: "My page"
              find("#page_body_translations_en", visible: false).set("The content of the page")
              fill_in "page_slug", with: "new-page"
              fill_in "page_published_on", with: chosen_publication_date

              click_link "ES"
              fill_in "page_title_translations_es", with: "Mi página"
              find("#page_body_translations_es", visible: false).set("Contenido de la página")

              click_button "Create"

              assert has_message?("Page created successfully")
              assert has_field?("page_slug", with: "new-page")
              assert_equal chosen_publication_date.to_s, air_datepicker_field_value(:page_published_on)

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
        Timecop.return
      end

    end
  end
end
