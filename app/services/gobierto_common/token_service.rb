# frozen_string_literal: true

module GobiertoCommon
  class TokenService
    DEFAULT_ALGORITHM = "HS256"

    def initialize(args = {})
      args = args.with_indifferent_access
      @secret = args[:secret] || APP_CONFIG["jwt_config"]["default_secret"] || ""
      @algorithm = args[:algorithm] || DEFAULT_ALGORITHM

      Rollbar.error(Exception.new("[GobiertoCommon] TokenService initialized with blank secret")) if @secret.blank?
    end

    def encode(data = {})
      JWT.encode(data, @secret, @algorithm)
    end

    def decode(token)
      return false unless token

      decoded_data = JWT.decode(token, @secret, true, algorithm: @algorithm)
      decoded_data[0]
    rescue JWT::VerificationError, JWT::DecodeError
      false
    end
  end
end
