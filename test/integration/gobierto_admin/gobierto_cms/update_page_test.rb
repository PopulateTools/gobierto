# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCms
    class UpdatePageTest < ActionDispatch::IntegrationTest
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

      def test_update_page
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path
              within "tr#collection-item-#{collection.id}" do
                click_link "News"
              end

              assert has_selector?("h1", text: collection.title)

              click_link "Consultation page FAQ"

              fill_in "page_title_translations_en", with: "Consultation page FAQ updated"
              fill_in "page_slug", with: "consultation-faq-updated"

              click_button "Update"

              assert has_message?("Page updated successfully")
              assert has_field?("page_slug", with: "consultation-faq-updated")

              assert_equal(
                "This is the body of the page",
                find("#body_translations_en", visible: false).value
              )
            end
          end
        end
      end
    end
  end
end
