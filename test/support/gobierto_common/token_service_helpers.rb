# frozen_string_literal: true

module GobiertoCommon
  module TokenServiceHelpers

    def with_stubbed_jwt_default_secret(secret)
      Object.stub_const(:APP_CONFIG, APP_CONFIG.dup.tap { |config| config["jwt_config"]["default_secret"] = secret }) do
        yield
      end
    end

  end
end
