# frozen_string_literal: true

module FileUploaderHelpers

  def with_stubbed_s3_file_upload(public_url = default_public_url)
    FileUploader::S3.stub_any_instance(:call, public_url) do
      FileUploader::S3.stub_any_instance(:uploaded_file_exists?, true) do
        yield
      end
    end
  end

  def with_stubbed_s3_upload!
    FileUploader::S3.stub_any_instance(:upload, nil) do
      yield
    end
  end

  def with_stubbed_local_file_upload(public_url = default_public_url)
    FileUploader::Local.stub_any_instance(:call, public_url) do
      yield
    end
  end

  private

  def default_public_url
    "http://www.madrid.es/assets/images/logo-madrid.png"
  end

end
