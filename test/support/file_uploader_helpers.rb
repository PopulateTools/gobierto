# frozen_string_literal: true

module FileUploaderHelpers
  def with_stubbed_s3_file_upload
    FileUploader::S3.stub_any_instance(:call, public_url) do
      yield
    end
  end

  def with_stubbed_s3_upload!
    FileUploader::S3.stub_any_instance(:upload, nil) do
      yield
    end
  end

  def public_url
    "http://www.madrid.es/assets/images/logo-madrid.png"
  end
end
