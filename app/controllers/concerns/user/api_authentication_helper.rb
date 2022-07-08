# frozen_string_literal: true

module User::ApiAuthenticationHelper
  extend ActiveSupport::Concern

  private

  def current_user
    @current_user ||= find_current_user
  end

  def user_signed_in?
    current_user.present?
  end

  def admin_authorized?
    (@current_admin = find_current_admin).present? &&
      @current_admin.sites.include?(current_site)
  end

  def authenticate_user!
    raise_unauthorized unless user_signed_in?
  end

  # The host is not checked if request is internal or the site is not password
  # protected
  def check_host
    return if internal_site_request? || !site_protected? || api_token_with_host.present?

    raise_unauthorized
  end

  def authenticate_in_site
    return if token.present? && (user_signed_in? || admin_authorized?)

    authenticate_user_in_site unless internal_site_request?
  end

  def internal_site_request?
    @internal_site_request ||= begin
                                 if referrer_host.present?
                                   referrer_host == current_site.domain || Site.where(domain: referrer_host).exists?
                                 else
                                   false
                                 end
                               end
  end

  def find_current_user
    current_site.users.confirmed.joins(:api_tokens).find_by(user_api_tokens: { token: token })
  end

  def find_current_admin
    @current_admin ||= if token.present?
                         ::GobiertoAdmin::Admin.joins(:api_tokens).find_by(admin_api_tokens: { token: token })
                       elsif session[:admin_id].present?
                         # This way of loading the admin works only on API calls called from the Gobierto UI
                         ::GobiertoAdmin::Admin.find(session[:admin_id])
                       end
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
    @api_token_with_host ||= ::User::ApiToken.where(domain: [nil, referrer_host]).find_by(token: token) || ::GobiertoAdmin::ApiToken.where(domain: [nil, referrer_host]).find_by(token: token)
  end

  def referrer_host
    @referrer_host ||= URI.parse(request.referrer)&.host if request.referrer.present?
  end
end
