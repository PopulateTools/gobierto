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

      def test_create_page
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              click_link "New"

              fill_in "Title", with: "My page"
              find("#page_body", visible: false).set("The content of the page")
              fill_in "URL", with: "new-page"

              click_button "Create"

              assert has_message?("Page created successfully")
              assert has_selector?("h1", text: "My page")
              assert has_field?("page_slug", with: "new-page")

              assert_equal(
                "<div>The content of the page</div>",
                find("#page_body", visible: false).value
              )

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
