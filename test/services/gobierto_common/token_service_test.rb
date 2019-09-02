# frozen_string_literal: true

require "test_helper"

module GobiertoCommon
  class TokenServiceTest < ActiveSupport::TestCase
    include GobiertoCommon::TokenServiceHelpers

    def default_secret
      @default_secret ||= "S3cr3t"
    end

    def token_service
      @token_service ||= TokenService.new
    end

    def token_service_with_secret
      @token_service_with_secret ||= TokenService.new(secret: "another_secret")
    end

    def payload
      @payload ||= { "sub" => "login", "api_token" => "token00001" }
    end

    def test_encode
      with_stubbed_jwt_default_secret(default_secret) do
        refute_equal token_service.encode(payload), token_service_with_secret.encode(payload)
        assert_equal token_service.encode(payload), TokenService.new(secret: default_secret).encode(payload)
      end
    end

    def test_decode
      with_stubbed_jwt_default_secret(default_secret) do
        encoded1 = token_service.encode(payload)
        encoded2 = token_service_with_secret.encode(payload)

        assert_equal payload, token_service.decode(encoded1)
        assert_equal payload, token_service_with_secret.decode(encoded2)
        refute token_service.decode(encoded2)
        refute token_service_with_secret.decode(encoded1)
      end
    end

  end
end
