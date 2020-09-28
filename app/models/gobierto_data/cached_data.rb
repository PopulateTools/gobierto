# frozen_string_literal: true

module GobiertoData
  class CachedData
    CACHED_DATA_BASE_PATH = "gobierto_data/cache/"

    attr_reader :resource, :resource_path

    def initialize(resource)
      @resource = resource
      @resource_path = "#{CACHED_DATA_BASE_PATH}#{resource.class.name.underscore}/#{resource.id}"
      @local = ::GobiertoCommon::FileUploadService.new(file_name: resource_path).adapter.is_a? ::FileUploader::Local
    end

    def local?
      @local
    end

    def source(name, update: false)
      update_method = update ? :upload! : :call
      service = GobiertoCommon::FileUploadService.new(file_name: "#{resource_path}/#{name}")
      service = GobiertoCommon::FileUploadService.new(file_name: "#{resource_path}/#{name}", content: yield) if update || !service.uploaded_file_exists?
      local? ? Rails.root.join("public#{service.send(update_method)}") : service.send(update_method)
    end
  end
end
