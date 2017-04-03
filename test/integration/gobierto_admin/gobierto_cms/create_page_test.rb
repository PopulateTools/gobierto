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

      def test_create_page_errors
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              click_link "New"
              click_button "Create"

              assert has_alert?("Title can't be blank")
              assert has_alert?("Body can't be blank")
              assert has_alert?("URL can't be blank")
            end
          end
        end
      end

      def test_create_page
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              click_link "New"

              fill_in "page_title_translations_en", with: "My page"
              find("#page_body_translations_en", visible: false).set("The content of the page")
              fill_in "page_slug_translations_en", with: "new-page"

              click_link "ES"
              fill_in "page_title_translations_es", with: "Mi página"
              find("#page_body_translations_es", visible: false).set("Contenido de la página")
              fill_in "page_slug_translations_es", with: "nueva-pagina"

              click_button "Create"

              assert has_message?("Page created successfully")
              assert has_selector?("h1", text: "My page")
              assert has_field?("page_slug_translations_en", with: "new-page")

              assert_equal(
                "<div>The content of the page</div>",
                find("#page_body_translations_en", visible: false).value
              )

              click_link "ES"

              assert_equal(
                "<div>Contenido de la página</div>",
                find("#page_body_translations_es", visible: false).value
              )

             assert has_field?("page_slug_translations_es", with: "nueva-pagina")

              page = site.pages.last
              activity = Activity.last
              assert_equal page, activity.subject
              assert_equal admin, activity.author
              assert_equal site.id, activity.site_id
              assert_equal "gobierto_cms.page_created", activity.action
            end
          end
        end
      end
    end
  end
end
