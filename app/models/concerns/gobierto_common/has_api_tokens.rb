# frozen_string_literal: true

module GobiertoCommon
  module HasApiTokens
    extend ActiveSupport::Concern

    included do
      has_many :api_tokens, dependent: :destroy
      after_create :primary_api_token!
    end

    def primary_api_token!
      primary_api_token || api_tokens.create(primary: true)
    end

    def primary_api_token
      api_tokens.where(primary: true).take
    end

  end
end
