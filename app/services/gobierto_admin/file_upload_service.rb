require "file_uploader"

module GobiertoAdmin
  class FileUploadService
    attr_reader :file, :site, :collection

    def initialize(adapter:, site:, collection:, attribute_name:, file:)
      @adapter = adapter
      @site = site
      @collection = collection
      @attribute_name = attribute_name
      @file = file
    end

    delegate :call, to: :adapter

    def adapter
      if Rails.env.development?
        return FileUploader::Local.new(file: file, file_name: file_name)
      end

      case @adapter
      when :s3 then FileUploader::S3.new(file: file, file_name: file_name)
      end
    end

    private

    def file_name
      @file_name ||= begin
        [site_id, collection, attribute_name].join("/")
      end
    end

    protected

    def site_id
      site.present? ? "site-#{site.id}" : "site-unknown"
    end

    def attribute_name
      "#{@attribute_name}-#{SecureRandom.uuid}"
    end
  end
end
