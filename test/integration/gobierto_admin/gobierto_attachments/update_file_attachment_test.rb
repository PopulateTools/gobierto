require 'test_helper'

module GobiertoAdmin
  module GobiertoAttachments
    class UpdateAttachmentTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_attachments_file_attachments_path
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def attachment_file
        @attachment_file ||= gobierto_attachments_attachment(:pdf_collection_attachment)
      end

      def test_update_page
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path
              click_link 'Files'
              assert has_selector?('h1', text: 'Files')
              click_link 'PDF Collection Attachment Name'

              fill_in 'file_attachment_name', with: 'File attachment name updated'
              fill_in 'file_attachment_description', with: 'File attachment description updated'

              click_button 'Update'

              assert has_message?('Attachment updated successfully.')
              assert has_field?('file_attachment_name', with: 'File attachment name updated')
              assert has_field?('file_attachment_description', with: 'File attachment description updated')
            end
          end
        end
      end
    end
  end
end
