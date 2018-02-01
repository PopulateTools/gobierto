require "file_uploader"

module GobiertoAdmin
  class FileUploadService
    attr_reader :file, :site, :collection, :x, :y, :w, :h

    def initialize(site:, collection:, attribute_name:, file:, x: nil, y: nil, w: nil, h: nil, content_disposition: nil, add_suffix: true)
      @adapter = APP_CONFIG['file_uploads_adapter'].presence.try(:to_sym) || :s3
      @site = site
      @collection = collection
      @attribute_name = attribute_name
      @file = crop_image(x, y, w, h, file)
      @content_disposition = content_disposition
      @add_suffix = add_suffix
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

    def crop_image(x, y, w, h, file)
      if x.present? && x.positive?
        x = x.to_i
        y = y.to_i
        width = w.to_i
        height = h.to_i
        image_response = ::Cloudinary::Uploader.upload(file.tempfile.path,
                                                       width: width,
                                                       height: height,
                                                       x: x,
                                                       y: y,
                                                       crop: :crop,
                                                       format: "png")
        url = image_response["url"]

        tmp_file = Tempfile.new
        tmp_file.binmode
        tmp_file.write(open(url).read)

        uploaded_file = ActionDispatch::Http::UploadedFile.new(tempfile: tmp_file,
                                                               original_filename: file.original_filename)
        uploaded_file.original_filename = file.original_filename
        uploaded_file.content_type = file.content_type
        uploaded_file.headers = file.headers
        uploaded_file
      else
        file
      end
    end

    private

    def file_name
      @file_name ||= begin
        [site_id, collection, attribute_name, file.original_filename].join("/")
      end
    end

    protected

    def site_id
      site.present? ? "site-#{site.id}" : "site-unknown"
    end

    def attribute_name
      if @add_suffix
        "#{@attribute_name}-#{SecureRandom.uuid}"
      else
        @attribute_name
      end
    end
  end
end
