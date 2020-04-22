# frozen_string_literal: true

module GobiertoAdmin
  class ApiToken < ApplicationRecord
    include ::GobiertoCommon::ActsAsApiToken

    acts_as_api_token_on :admin, class_name: "GobiertoAdmin::Admin"
  end
end
