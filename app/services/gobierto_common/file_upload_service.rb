# frozen_string_literal: true

require "file_uploader"

module GobiertoCommon
  class FileUploadService
    attr_reader :file, :site, :collection

    def initialize(args = {})
      @adapter = APP_CONFIG["file_uploads_adapter"].presence.try(:to_sym) || :s3
      @site = args[:site]
      @collection = args[:collection]
      @attribute_name = args[:attribute_name]
      @file_name = args[:file_name]
      @file ||= if args[:content].present?
                @tmp_file = Tempfile.new
                @tmp_file.binmode
                @tmp_file.write(args[:content])
                @tmp_file.close
                ActionDispatch::Http::UploadedFile.new(filename: @file_name.split("/").last, tempfile: @tmp_file, original_filename: @file_name.split(""))
              else
                args[:file]
              end
      @content_disposition = args[:content_disposition]
      @content_type = args[:content_type]
      @add_suffix = args[:add_suffix] || true
    end

    delegate :call, :uploaded_file_exists?, :upload!, to: :adapter

    def adapter
      if Rails.env.development?
        return FileUploader::Local.new(file: file, file_name: file_name)
      end

      case @adapter
      when :s3 then FileUploader::S3.new(file: file, file_name: file_name, content_disposition: @content_disposition)
      when :filesystem then FileUploader::Local.new(file: file, file_name: file_name)
      end
    end

    private

    def file_name
      @file_name ||= begin
        [site_id, collection, attr_name, file.original_filename].join("/")
      end
    end

    protected

    def site_id
      site.present? ? "site-#{site.id}" : "site-unknown"
    end

    def attr_name
      if @add_suffix
        "#{@attribute_name}-#{SecureRandom.uuid}"
      else
        @attribute_name
      end
    end
  end
end
