# frozen_string_literal: true

require "aws-sdk"

module FileUploader
  class S3
    attr_reader :file, :file_name

    def initialize(file_name:, content: nil, file: nil, content_disposition: nil, content_type: nil, bucket_name: nil)
      @file = if content.present?
                @tmp_file = Tempfile.new
                @tmp_file.binmode
                @tmp_file.write(content)
                @tmp_file.close
                ActionDispatch::Http::UploadedFile.new(filename: @file_name, tempfile: @tmp_file)
              else
                file
              end
      @file_name = file_name
      @bucket_name = bucket_name
      @content_disposition = content_disposition
      @content_type = content_type
    end

    def call
      if !uploaded_file_exists? && @file
        upload
      else
        object.public_url
      end
    end

    def upload
      upload! if !uploaded_file_exists? && @file
    end

    def upload!
      File.open(file.tempfile, 'rb') do |file_body|
        options = { body: file_body }
        options[:content_disposition] = @content_disposition if @content_disposition.present?
        options[:content_type] = @content_type if @content_type.present?

        object.put(options)
      end
      if @tmp_file
        @tmp_file.unlink
      end
      object.public_url
    end

    def uploaded_file_exists?
      object.exists?
    rescue Aws::S3::Errors::Forbidden
      false
    end

    def delete
      !uploaded_file_exists? || object.delete
    end

    private

    def resource
      Aws::S3::Resource.new(client: client)
    end

    def bucket_name
      @bucket_name ||= ENV.fetch("S3_BUCKET_NAME")
    end

    def object
      @object ||= resource.bucket(bucket_name).object(file_name)
    end

    protected

    def client
      Aws::S3::Client.new(
        region: ENV.fetch("AWS_REGION"),
        access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
        secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY")
      )
    end
  end
end
