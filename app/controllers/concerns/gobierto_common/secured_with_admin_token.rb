# frozen_string_literal: true

module GobiertoCommon
  module SecuredWithAdminToken
    extend ActiveSupport::Concern

    included do
      attr_accessor :current_admin

      before_action :set_admin_with_token
    end

    protected

    def set_admin_with_token
      @current_admin ||= ::GobiertoAdmin::Admin.joins(:api_tokens).find_by(admin_api_tokens: { token: token })

      render(json: { message: "Unauthorized" }, status: :unauthorized, adapter: :json_api) unless @current_admin.present?
    end

    def token
      token_and_options = ActionController::HttpAuthentication::Token.token_and_options(request)
      @token = token_and_options.present? ? token_and_options[0] : nil
    end

  end
end
