# frozen_string_literal: true

module User::ApiAuthenticationHelper
  extend ActiveSupport::Concern

  private

  def current_user
    @current_user ||= find_current_user
  end

  def user_authenticated?
    current_user.present?
  end

  def admin_authorized?
    find_current_admin.present? && current_admin.sites.include?(current_site)
  end

  def authenticate_user!
    raise_unauthorized unless user_authenticated?
  end

  def authenticate_in_site
    return if user_authenticated? || admin_authorized?

    authenticate_user_in_site
  end

  def find_current_user
    return unless token.present?

    current_site.users.confirmed.joins(:api_tokens).find_by(user_api_tokens: { token: token })
  end

  def find_current_admin
    return unless token.present?

    @current_admin ||= ::GobiertoAdmin::Admin.joins(:api_tokens).find_by(admin_api_tokens: { token: token })
  end

  def raise_unauthorized
    render(json: { message: "Unauthorized" }, status: :unauthorized, adapter: :json_api) && return
  end

  def token
    token_and_options = ActionController::HttpAuthentication::Token.token_and_options(request)
    @token = token_and_options.present? ? token_and_options[0] : params["token"]
  end
end
