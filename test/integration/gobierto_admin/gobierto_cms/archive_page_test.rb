# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCms
    class ArchivePageTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_participation_process_pages_path(process_id: process.id)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def process
        @process ||= gobierto_participation_processes(:sport_city_process)
      end

      def themes_page
        @themes_page ||= gobierto_cms_pages(:themes)
      end

      def consultation_faq_page
        @consultation_faq_page ||= gobierto_cms_pages(:consultation_faq)
      end

      def site_pages_collection
        ::GobiertoCommon::Collection.find_by(container: site, item_type: "GobiertoCms::Page")
      end

      def test_archive_restore_page
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "#page-item-#{themes_page.id}" do
                find("a[data-method='delete']").click
              end

              page.driver.browser.switch_to.alert.accept

              assert has_message?("Page archived successfully")

              click_on "Archived elements"

              within "tr#page-item-#{themes_page.id}" do
                click_on "Recover element"
              end

              page.driver.browser.switch_to.alert.accept

              assert has_message?("The page has been successfully recovered")
            end
          end
        end
      end

      def test_archive_error
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit admin_common_collection_path(site_pages_collection)

              within "#page-item-#{consultation_faq_page.id}" do
                find("a[data-method='delete']").click
              end

              page.driver.browser.switch_to.alert.accept

              assert has_message?("The page can not be deleted because it still has associated elements")
            end
          end
        end
      end

    end
  end
end
