# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCms
    class PageAttachmentsTest < ActionDispatch::IntegrationTest
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

      def test_list_page_attachments
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              click_link cms_page.title

              assert has_content?("XLSX Attachment Name")
            end
          end
        end
      end

      def test_list_site_attachments
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              click_link cms_page.title

              page.find("#show-modal").trigger("click")
              assert has_content?("XLSX Attachment Name")
              assert has_content?("PDF Attachment Name")
            end
          end
        end
      end
    end
  end
end
