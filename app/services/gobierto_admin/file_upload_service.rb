# frozen_string_literal: true

require 'file_uploader'

module GobiertoAdmin
  class FileUploadService
    attr_reader :file, :site, :collection

    def initialize(site:, collection:, attribute_name:, file:, content_disposition: nil)
      @adapter = APP_CONFIG['file_uploads_adapter'].presence.try(:to_sym) || :s3
      @site = site
      @collection = collection
      @attribute_name = attribute_name
      @file = file
      @content_disposition = content_disposition
    end

    delegate :call, to: :adapter

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
        [site_id, collection, attribute_name, file.original_filename].join('/')
      end
    end

    protected

    def site_id
      site.present? ? "site-#{site.id}" : 'site-unknown'
    end

    def attribute_name
      "#{@attribute_name}-#{SecureRandom.uuid}"
    end
  end
end
