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

  def check_host
    return if internal_site_request? || !site_protected? || token.present? && valid_token_domain?

    raise_unauthorized
  end

  def authenticate_in_site
    return if token.present? && (user_authenticated? || admin_authorized?)

    authenticate_user_in_site unless internal_site_request?
  end

  def valid_token_domain?
    return unless api_token.present?

    api_token.domain.blank? || api_token.domain == request.host
  end

  def internal_site_request?
    Site.where(domain: request.host).exists?
  end

  def find_current_user
    return unless internal_site_request? || valid_token_domain?

    current_site.users.confirmed.joins(:api_tokens).find_by(user_api_tokens: { token: token })
  end

  def find_current_admin
    return unless internal_site_request? || valid_token_domain?

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

  def api_token
    @api_token ||= ::User::ApiToken.find_by(token: token) || ::GobiertoAdmin::ApiToken.find_by(token: token)
  end
end
