# frozen_string_literal: true

class User::ApiToken < ApplicationRecord
  include GobiertoCommon::ActsAsApiToken

  acts_as_api_token_on :user
  delegate :site, to: :user
end
