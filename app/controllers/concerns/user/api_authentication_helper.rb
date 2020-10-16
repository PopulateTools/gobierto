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

  # The host is not checked if request is internal or the site is not password
  # protected
  def check_host
    return if internal_site_request? || !site_protected? || api_token_with_host.present?

    raise_unauthorized
  end

  def authenticate_in_site
    return if token.present? && (user_authenticated? || admin_authorized?)

    authenticate_user_in_site unless internal_site_request?
  end

  def internal_site_request?
    @internal_site_request ||= request.host == current_site.domain || Site.where(domain: request.host).exists?
  end

  def find_current_user
    current_site.users.confirmed.joins(:api_tokens).find_by(user_api_tokens: { token: token })
  end

  def find_current_admin
    @current_admin ||= ::GobiertoAdmin::Admin.joins(:api_tokens).find_by(admin_api_tokens: { token: token })
  end

  def raise_unauthorized
    render(json: { message: "Unauthorized" }, status: :unauthorized, adapter: :json_api) && return
  end

  def token
    @token ||= begin
                 token_and_options = ActionController::HttpAuthentication::Token.token_and_options(request)
                 token_and_options.present? ? token_and_options[0] : params["token"]
               end
  end

  # The ApiToken associated domain must be blank or coincident with the host
  # request
  def api_token_with_host
    @api_token_with_host ||= ::User::ApiToken.where(domain: [nil, request.host]).find_by(token: token) || ::GobiertoAdmin::ApiToken.where(domain: [nil, request.host]).find_by(token: token)
  end
end
