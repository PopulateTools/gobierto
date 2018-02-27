# frozen_string_literal: true

require "test_helper"
require "support/cloudinary_helpers"

module GobiertoAdmin
  class CloudinaryServiceTest < ActiveSupport::TestCase
    include CloudinaryHelpers

    def cloudinary_service
      @cloudinary_service ||= ::GobiertoAdmin::CloudinaryService.new(
        path: "http://www.madrid.es/assets/images/logo-madrid.png",
        crop: :crop,
        x: 10,
        y: 10,
        width: 1500,
        height: 1500
      )
    end

    def test_call
      with_stubbed_cloudinary_response do
        image_response = cloudinary_service.call.first
        assert_equal 1000, image_response["width"]
        assert_equal 1000, image_response["height"]
        assert_includes image_response, "secure_url"
      end
    end
  end
end
