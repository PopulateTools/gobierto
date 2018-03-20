# frozen_string_literal: true

module GobiertoAdmin
  class CloudinaryService
    def initialize(path:, crop:, x: nil, y: nil, width: nil, height: nil)
      @path = path
      @crop = crop
      @x = x
      @y = y
      @width = width
      @height = height
    end

    def call
      ::Cloudinary::Uploader.upload(@path,
                                    crop: @crop,
                                    x: @x,
                                    y: @y,
                                    width: @width,
                                    height: @height)
    end
  end
end
