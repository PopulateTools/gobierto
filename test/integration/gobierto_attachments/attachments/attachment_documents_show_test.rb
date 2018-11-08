# frozen_string_literal: true

require "test_helper"

module GobiertoAttachments
  module Attachments
    class AttachmentDocumentsShowTest < ActionDispatch::IntegrationTest

      def site
        @site ||= sites(:madrid)
      end

      def participation_attachment
        @participation_attachment ||= gobierto_attachments_attachments(:pdf_on_bowling_group_very_active_process)
      end

      def draft_participation_process_attachment
        @draft_participation_process_attachment ||= gobierto_attachments_attachments(:pdf_on_cultural_city_group)
      end

      def participation_process
        @participation_process ||= gobierto_participation_processes(:bowling_group_very_active)
      end

      def draft_participation_process
        @draft_participation_process ||= gobierto_participation_processes(:cultural_city_group_draft)
      end

      def png_attachment
        @png_attachment ||= gobierto_attachments_attachments(:png_attachment_uploaded)
      end

      def test_view_attachment_without_context
        with_current_site(site) do
          visit gobierto_attachments_document_url(png_attachment, host: site.domain)

          assert has_content? png_attachment.description
        end
      end

      def test_view_attachment_document_in_draft_process
        with_current_site(site) do
          visit gobierto_attachments_document_url(draft_participation_process_attachment, host: site.domain)

          assert has_content? "The page you were looking for doesn't exist."
        end
      end

      def test_view_attachment_document_in_participation_process_context
        with_current_site(site) do
          visit gobierto_attachments_document_url(participation_attachment, host: site.domain)

          assert has_content? participation_attachment.description
          assert has_content? participation_process.title
        end
      end

      def test_wrong_url
        with_current_site(site) do
          visit gobierto_attachments_document_url(id: "wadus", host: site.domain)
          assert has_content? "The page you were looking for doesn't exist."
        end
      end

    end
  end
end
