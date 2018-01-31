require "file_uploader"

module GobiertoAdmin
  class FileUploadService
    attr_reader :file, :site, :collection, :x, :y, :w, :h

    def initialize(site:, collection:, attribute_name:, file:, x:, y:, w:, h:, content_disposition: nil, add_suffix: true)
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
      unless x.blank?
        # manipulate! do |file|

          x = x.to_f
          y = y.to_f
          w = w.to_f
          h = h.to_f
          #img.crop "#{w}x#{h}+#{x}+#{y}"
          #image.crop "20x30+10+5"

          #file.crop([[w, h].join('x'), [x, y].join('+')].join('+'))
        # end
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
