# frozen_string_literal: true

require "test_helper"

module FileUploader
  class LocalTest < Minitest::Test
    def local_file_uploader
      @local_file_uploader ||= FileUploader::Local.new(
        file: file,
        file_name: "people/person/avatar.jpg"
      )
    end

    def file
      @file ||= Rack::Test::UploadedFile.new(
        File.open(
          File.join(
            ActionDispatch::IntegrationTest.fixture_path,
            "files/gobierto_people/people/avatar.jpg"
          )
        ),
        original_filename: "avatar.jpg"
      )
    end

    def test_call
      assert_equal "/system/attachments/people/person/avatar.jpg", local_file_uploader.call
    end
  end
end
