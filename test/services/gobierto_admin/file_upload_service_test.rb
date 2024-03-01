# frozen_string_literal: true

require "test_helper"
require "support/file_uploader_helpers"

module GobiertoAdmin
  class FileUploadServiceTest < ActiveSupport::TestCase
    include FileUploaderHelpers

    def file_upload_service
      @file_upload_service ||= ::GobiertoCommon::FileUploadService.new(
        site: site,
        collection: :test_collection,
        attribute_name: :test_attribute,
        file: file
      )
    end

    def site
      @site ||= sites(:madrid)
    end

    def file
      @file ||= Rack::Test::UploadedFile.new(
        File.join(
          ActionDispatch::IntegrationTest.fixture_path,
          "files/gobierto_people/people/avatar.jpg"
        )
      )
    end

    def test_adapter
      Object.stub_const(:APP_CONFIG, APP_CONFIG.dup.tap { |config| config[:file_uploads_adapter] = "s3" }) do
        assert_kind_of FileUploader::S3, file_upload_service.adapter
        assert_equal file, file_upload_service.adapter.file
        assert_includes file_upload_service.adapter.file_name, "site-#{site.id}/test_collection/test_attribute"
        assert_includes file_upload_service.adapter.file_name, file.original_filename
      end
    end

    def test_adapter_in_development
      Rails.env.stub(:development?, true) do
        assert_kind_of FileUploader::Local, file_upload_service.adapter
        assert_equal file, file_upload_service.adapter.file
        assert_includes file_upload_service.adapter.file_name, "site-#{site.id}/test_collection/test_attribute"
        assert_includes file_upload_service.adapter.file_name, file.original_filename
      end
    end

    def test_call
      with_stubbed_s3_file_upload do
        assert file_upload_service.call
      end
    end
  end
end
