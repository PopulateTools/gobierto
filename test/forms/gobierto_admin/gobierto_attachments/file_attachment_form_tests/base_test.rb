# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  module GobiertoAttachments
    module FileAttachmentFormTests
      class BaseTest < ActiveSupport::TestCase

        def setup
          super
          [::FileUploader::S3, ::FileUploader::Local].each do |file_uploader|
            file_uploader.any_instance
              .stubs(:upload!)
              .returns('http://www.domain.com/logo-madrid.png')
            file_uploader.any_instance
              .stubs(:call)
              .returns('http://www.domain.com/logo-madrid.png')

          end
        end

        def site
          @site ||= sites(:madrid)
        end

        def admin
          @admin ||= gobierto_admin_admins(:tony)
        end

        def uploaded_file
          @uploaded_file ||= Rack::Test::UploadedFile.new(
            Rails.root.join('test/fixtures/files/sites/logo-madrid.png')
          )
        end

        def existing_attachment_file
          @existing_attachment_file ||= Rack::Test::UploadedFile.new(
            Rails.root.join('test/fixtures/files/gobierto_attachments/attachment/pdf-attachment.pdf')
          )
        end

        def file_attachment_class
          ::GobiertoAttachments::Attachment
        end

      end
    end
  end
end
