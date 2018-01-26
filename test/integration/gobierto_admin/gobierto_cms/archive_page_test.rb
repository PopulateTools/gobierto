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

      def test_archive_restore_page
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "#page-item-#{themes_page.id}" do
                find("a[data-method='delete']").click
              end

              assert has_message?("Page archived successfully")

              click_on "Archived elements"

              within "tr#page-item-#{themes_page.id}" do
                click_on "Recover element"
              end

              assert has_message?("The page has been successfully recovered")
            end
          end
        end
      end
    end
  end
end
