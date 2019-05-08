# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoAttachments
    class ArchiveFileAttachmentTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_participation_process_file_attachments_path(process_id: process.id)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def process
        @process ||= gobierto_participation_processes(:gender_violence_process)
      end

      def pdf_attachment
        @pdf_attachment ||= gobierto_attachments_attachments(:pdf_collection_attachment)
      end

      def test_archive_restore_file_attachment
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "#file_attachment-item-#{pdf_attachment.id}" do
                find("a[data-method='delete']").click
              end

              page.accept_alert

              assert has_message?("Attachment archived successfully")

              click_on "Archived elements"

              within "tr#file_attachment-item-#{pdf_attachment.id}" do
                click_on "Recover element"
              end

              page.accept_alert

              assert has_message?("Attachment recovered successfully")
            end
          end
        end
      end
    end
  end
end
