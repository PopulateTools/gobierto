# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoAttachments
    class AttachingTest < ActionDispatch::IntegrationTest
      def site
        @site ||= sites(:madrid)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def pdf_attachment
        @pdf_attachment ||= gobierto_attachments_attachments(:pdf_attachment)
      end

      def xlsx_attachment
        @xlsx_attachment ||= gobierto_attachments_attachments(:xlsx_attachment)
      end

      def cms_page
        @cms_page ||= gobierto_cms_pages(:consultation_faq)
      end

      def attaching
        @attaching ||= gobierto_attachments_attachings(:consultation_faq_xlsx_attachment)
      end

      def attachment_attributes
        @attachment_attributes ||= %w(id site_id name description file_name file_digest url human_readable_url human_readable_path file_size current_version created_at)
      end

      def test_attachings_create_success
        login_admin_for_api(admin)

        payload = {
          attachment_id: pdf_attachment.id,
          attachable_id: cms_page.id,
          attachable_type: cms_page.class.to_s
        }

        post admin_attachments_api_attachings_path(payload)

        response_body = JSON.parse(response.body)
        attachment = response_body["attachment"]

        assert_response :success

        assert array_match(attachment_attributes, attachment.keys)

        assert_equal "PDF Attachment Name", attachment["name"]
        assert_equal "http://host.com/attachments/super-long-and-ugly-aws-id/pdf-attachment.pdf", attachment["url"]
        assert_equal 3, cms_page.reload.attachments.count
      end

      def test_attachings_create_error
        login_admin_for_api(admin)

        unexistent_id = 666

        payload = {
          attachment_id: unexistent_id,
          attachable_id: cms_page.id,
          attachable_type: cms_page.class.to_s
        }

        post admin_attachments_api_attachings_path(payload)

        assert_response :not_found
      end

      def test_attachings_destroy_success
        login_admin_for_api(admin)

        payload = {
          attachment_id: xlsx_attachment.id,
          attachable_id: cms_page.id,
          attachable_type: cms_page.class.to_s
        }

        delete admin_attachments_api_attachings_path, params: payload

        assert_response :success

        assert_raises ActiveRecord::RecordNotFound do
          ::GobiertoAttachments::Attaching.find_by!(site: site, attachment: xlsx_attachment, attachable: cms_page, attachable_type: cms_page.class.to_s)
        end
      end

      def test_attachings_destroy_error
        login_admin_for_api(admin)

        unexistent_id = 666

        payload = {
          attachment_id: unexistent_id,
          attachable_id: cms_page.id,
          attachable_type: cms_page.class.to_s
        }

        delete admin_attachments_api_attachings_path, params: payload

        assert_response :not_found
      end
    end
  end
end
