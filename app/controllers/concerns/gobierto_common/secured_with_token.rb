# frozen_string_literal: true

module GobiertoCommon
  module SecuredWithToken
    extend ActiveSupport::Concern

    included do
      attr_accessor :current_admin

      before_action :set_admin_with_token
    end

    protected

    def set_admin_with_token
      extract_token

      # TODO: Implement bad request
      decoded_data = GobiertoCommon::TokenService.new.decode(@token)
      if decoded_data && decoded_data["sub"] == "login" && (admin = ::GobiertoAdmin::Admin.find_by(api_token: decoded_data["api_token"]))
        @current_admin = admin
      else
        send_unauthorized
      end
    end

    def extract_token
      token_and_options = ActionController::HttpAuthentication::Token.token_and_options(request)
      @token = token_and_options.present? ? token_and_options[0] : nil
    end

  end
end
