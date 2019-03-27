# frozen_string_literal: true

require "test_helper"

module GobiertoAttachments
  module Attachments
    class AttachmentShowTest < ActionDispatch::IntegrationTest

      def site
        @site ||= sites(:madrid)
      end

      def png_attachment
        @png_attachment ||= gobierto_attachments_attachments(:png_attachment_uploaded)
      end

      def page_with_attachments
        @page_with_attachments ||= gobierto_cms_pages(:about_site)
      end

      def test_view_attachment_directly
        ::GobiertoAttachments::AttachmentsController.any_instance.stubs(:direct_visit?).returns(true)

        with_current_site(site) do
          visit gobierto_attachments_attachment_url(png_attachment, host: site.domain)

          # a friendly URL is displayed to the user
          assert_equal png_attachment.human_readable_path, current_path

          # an iframe will be shown, with the image inside
          assert_equal png_attachment.url, find("iframe")["src"]
        end
      end

      def test_view_attachment_included_in_page
        with_current_site(site) do
          visit gobierto_cms_page_path(page_with_attachments.slug)

          # image will be rendered inside page, the URL will be the friendly one,
          # since it's been added by the user in the page markdown editor
          assert all("img").map { |node| node["src"] }.any? { |img_src| img_src.include? png_attachment.human_readable_path }
        end
      end

    end
  end
end
