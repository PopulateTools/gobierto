# frozen_string_literal: true

module GobiertoData
  class CachedData
    CACHED_DATA_BASE_PATH = "gobierto_data/cache/"
    CONTENT_TYPES = {
      ".json" => "application/json; charset=utf-8",
      ".csv" => "text/csv; charset=utf-8",
      ".xlsx" => "application/xlsx"
    }.freeze

    attr_reader :resource, :resource_path

    def initialize(resource)
      @resource = resource
      @resource_path = "#{CACHED_DATA_BASE_PATH}#{resource.class.name.underscore}/#{resource.id}"
      @local = ::GobiertoCommon::FileUploadService.new(file_name: resource_path).adapter.is_a? ::FileUploader::Local
    end

    def local?
      @local
    end

    def delete_cached_data
      ::GobiertoCommon::FileUploadService.new(file_name: resource_path).delete_children
    end

    def source(name, update: false, content_type: nil)
      update_method = update ? :upload! : :call
      service = GobiertoCommon::FileUploadService.new(file_name: "#{resource_path}/#{name}")
      if update || !service.uploaded_file_exists?
        service = GobiertoCommon::FileUploadService.new(
          file_name: "#{resource_path}/#{name}",
          content: yield,
          content_disposition: "attachment",
          content_type: content_type || CONTENT_TYPES[File.extname(name)]
        )
      end
      local? ? Rails.root.join("public#{service.send(update_method)}") : service.send(update_method)
    end
  end
end
