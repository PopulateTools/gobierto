# frozen_string_literal: true

require "test_helper"
require "support/file_uploader_helpers"

module GobiertoAdmin
  class FileAttachmentFormTest < ActiveSupport::TestCase
    include FileUploaderHelpers

    def valid_file_attachment_form
      @valid_file_attachment_form ||= FileAttachmentForm.new(
        file: Rack::Test::UploadedFile.new(
          Rails.root.join("test/fixtures/files/sites/logo-madrid.png")
        ),
        site_id: site.id
      )
    end

    def valid_file_attachment_with_name_form
      @valid_file_attachment_with_name_form ||= FileAttachmentForm.new(
        file: Rack::Test::UploadedFile.new(
          Rails.root.join("test/fixtures/files/sites/logo-madrid.png")
        ),
        name: "wadus",
        site_id: site.id,
        collection: "wadus"
      )
    end

    def invalid_file_attachment_form
      @invalid_file_attachment_form ||= FileAttachmentForm.new(
        site_id: nil,
        file: nil,
        name: nil,
        description: nil
      )
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_validation
      assert valid_file_attachment_form.valid?
    end

    def test_validation_with_name
      assert valid_file_attachment_with_name_form.valid?
    end

    def test_error_messages_with_invalid_attributes
      with_stubbed_s3_file_upload do
        invalid_file_attachment_form.save
      end

      assert_equal 1, invalid_file_attachment_form.errors.messages[:file].size
    end

    def test_file_url
      with_stubbed_s3_file_upload do
        valid_file_attachment_form.save

        assert_equal(
          "http://www.madrid.es/assets/images/logo-madrid.png",
          valid_file_attachment_form.url
        )
      end
    end
  end
end
