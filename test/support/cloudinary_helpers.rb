# frozen_string_literal: true

module CloudinaryHelpers
  def with_stubbed_cloudinary_response
    ::GobiertoAdmin::CloudinaryService.stub_any_instance(:call, [cloudinary_response]) do
      yield
    end
  end

  def cloudinary_response
    {
      "width" => 1000,
      "height" => 1000,
      "secure_url" => "http://www.madrid.es/assets/images/logo-madrid.png"
    }
  end
end
