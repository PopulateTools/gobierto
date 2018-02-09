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
      y = y.to_i
      height = h.to_i

      if x.present? && x >= 0
        x = x.to_i
        width = w.to_i

        # Crop
        image_response = ::GobiertoAdmin::CloudinaryService.new(path: file.tempfile.path,
                                                                crop: :crop,
                                                                x: x,
                                                                y: y,
                                                                width: width,
                                                                height: height).call

        # Resize with max with 1000
        if image_response["width"] > 1000 || image_response["height"] > 1000
          if image_response["width"] > image_response["height"]
            image_response = ::GobiertoAdmin::CloudinaryService.new(path: image_response["secure_url"],
                                                                    crop: :scale,
                                                                    width: 1000).call
          end
        end

        file_from_url(image_response["secure_url"], file)
      elsif x.present? && x.negative?
        # Crop
        image_response = ::GobiertoAdmin::CloudinaryService.new(path: file.tempfile.path,
                                                                crop: :crop,
                                                                y: y,
                                                                height: height).call

        # Resize with max height 1000
        if image_response["width"] > 1000 || image_response["height"] > 1000
          if image_response["height"] > image_response["width"]
            image_response = ::GobiertoAdmin::CloudinaryService.new(path: image_response["secure_url"],
                                                                    crop: :scale,
                                                                    height: 1000).call
          end
        end

        file_from_url(image_response["secure_url"], file)
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

    def file_from_url(url, file)
      tmp_file = Tempfile.new
      tmp_file.binmode
      tmp_file.write(open(url).read)

      uploaded_file = ActionDispatch::Http::UploadedFile.new(tempfile: tmp_file,
                                                             original_filename: file.original_filename)
      uploaded_file.original_filename = file.original_filename
      uploaded_file.content_type = file.content_type
      uploaded_file.headers = file.headers
      uploaded_file
    end
  end
end
