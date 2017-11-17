# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCms
    class CreateSectionItemTest < ActionDispatch::IntegrationTest
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

      def cms_page
        @cms_page ||= gobierto_cms_pages(:consultation_faq)
      end

      def collection
        @collection ||= gobierto_common_collections(:news)
      end

      def section
        @section ||= gobierto_cms_sections(:participation)
      end

      def test_create_section_item
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "tr#collection-item-#{collection.id}" do
                click_link "News"
              end

              click_link "New"

              fill_in "page_title_translations_en", with: "My page with section"
              find("#page_body_translations_en", visible: false).set("The content of the page")
              fill_in "page_slug", with: "new-page-with-section"

              find("#permission_1", visible: false).trigger("click")
              find("select#page_section").find("option[value='#{section.id}']").select_option

              click_button "Create"

              assert has_message?("Page created successfully")
              assert has_field?("page_slug", with: "new-page-with-section")

              assert_equal(
                "<div>The content of the page</div>",
                find("#page_body_translations_en", visible: false).value
              )

              assert find("select#page_parent").value, section.title

              section_item = section.section_items.last
              assert_equal section_item.section.title, section.title
            end
          end
        end
      end
    end
  end
end
