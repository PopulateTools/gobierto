# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoParticipation
    class ProcessAttachmentsTest < ActionDispatch::IntegrationTest
      def setup
        super
        collection.append(attachment)
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

      def collection
        @collection ||= gobierto_common_collections(:gender_violence_process_documents)
      end

      def attachment
        @attachment ||= gobierto_attachments_attachments(:pdf_collection_attachment)
      end

      def test_attachments
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit edit_admin_participation_process_path(process)

            within ".tabs" do
              click_link "Documents"
            end

            assert has_content?(attachment.name)
          end
        end
      end

      def test_create_attachment
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit edit_admin_participation_process_path(process)

            within ".tabs" do
              click_link "Documents"
            end

            click_link "New"

            assert has_selector?("h1", text: process.title)

            fill_in "file_attachment_name", with: "My file_attachment"
            fill_in "file_attachment_description", with: "My file_attachment description"
            attach_file("file_attachment_file", "test/fixtures/files/gobierto_attachments/attachment/pdf-collection-gender-attachment.pdf")

            with_stubbed_s3_file_upload do
              click_button "Create"
            end
            assert has_message?("Attachment created successfully.")

            assert has_selector?("h1", text: process.title)

            within ".tabs" do
              click_link "Documents"
            end

            assert has_content?("My file_attachment")
          end
        end
      end

      def test_edit_attachment
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit edit_admin_participation_process_path(process)

            within ".tabs" do
              click_link "Documents"
            end

            click_link attachment.name

            assert has_selector?("h1", text: process.title)

            fill_in "file_attachment_name", with: "My file_attachment"
            fill_in "file_attachment_description", with: "My file_attachment description"
            attach_file("file_attachment_file", "test/fixtures/files/gobierto_attachments/attachment/pdf-collection-update-attachment.pdf")

            with_stubbed_s3_file_upload do
              click_button "Update"
            end

            assert has_message?("Attachment updated successfully.")

            assert has_selector?("h1", text: process.title)

            within ".tabs" do
              click_link "Documents"
            end

            assert has_content?("My file_attachment")
            refute has_content?(attachment.name)
          end
        end
      end
    end
  end
end
