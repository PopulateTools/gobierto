# frozen_string_literal: true

module GobiertoCommon
  module HasApiTokens
    extend ActiveSupport::Concern

    included do
      has_many :api_tokens, dependent: :destroy
      after_create :primary_api_token!
    end

    def primary_api_token!
      primary_api_token || api_tokens.primary.create
    end

    def primary_api_token
      api_tokens.primary.take
    end

  end
end
