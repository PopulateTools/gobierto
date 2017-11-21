# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  module GobiertoAttachments
    module FileAttachmentFormTests
      class BaseTest < ActiveSupport::TestCase

        def setup
          super
          ::FileUploader::S3.any_instance
                            .stubs(:call)
                            .returns('http://www.domain.com/logo-madrid.png')
        end

        def site
          @site ||= sites(:madrid)
        end

        def admin
          @admin ||= gobierto_admin_admins(:tony)
        end

        def uploaded_file
          @uploaded_file ||= Rack::Test::UploadedFile.new(
            File.open(Rails.root.join('test/fixtures/files/sites/logo-madrid.png')),
            original_filename: 'logo-madrid.png'
          )
        end

        def existing_attachment_file
          @existing_attachment_file ||= Rack::Test::UploadedFile.new(
            File.open(Rails.root.join('test/fixtures/files/gobierto_attachments/attachment/pdf-attachment.pdf')),
            original_filename: 'pdf-attachment.pdf'
          )
        end

        def file_attachment_class
          ::GobiertoAttachments::Attachment
        end

      end
    end
  end
end
