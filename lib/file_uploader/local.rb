module FileUploader
  class Local
    FILE_PATH_PREFIX = "attachments".freeze

    attr_reader :file, :file_name

    def initialize(file:, file_name:)
      @file = file
      @file_name = file_name
    end

    def call
      FileUtils.mkdir_p(file_base_path) unless File.exist?(file_base_path)
      FileUtils.mv(file.tempfile.path, file_path)
      ObjectSpace.undefine_finalizer(file.tempfile)

      file_uri
    end

    private

    def file_uri
      File.join("/", FILE_PATH_PREFIX, file_name)
    end

    def file_path
      File.join(file_base_path, file_basename)
    end

    def file_base_path
      File.join(
        defined?(Rails) ? Rails.public_path : "",
        FILE_PATH_PREFIX,
        file_dirname
      )
    end

    protected

    def file_dirname
      Pathname.new(file_name).dirname
    end

    def file_basename
      Pathname.new(file_name).basename
    end
  end
end
