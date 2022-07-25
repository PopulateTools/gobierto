module User::SessionHelper
  extend ActiveSupport::Concern

  included do
    if respond_to?(:helper_method)
      helper_method :current_user, :user_signed_in?
    end
  end

  private

  def current_user
    @current_user ||= find_current_user
  end

  def user_signed_in?
    current_user.present?
  end

  def admin_authorized?
    false
  end

  def sign_in_user(user_id)
    session[:user_id] = user_id
  end

  def sign_out_user
    @current_user = session[:user_id] = nil
  end

  def authenticate_user!
    raise_user_not_signed_in unless user_signed_in?
  end

  def require_no_authentication
    raise_user_already_authenticated if user_signed_in?
  end

  def find_current_user
    if session[:user_id].present?
      User.confirmed.find_by(id: session[:user_id], site_id: current_site.id)
    end
  end

  def after_sign_in_path(referrer_url = nil)
    referrer_url.presence || root_path
  end

  def after_sign_out_path
    root_path
  end

  def auth_modules_present?
    current_site.configuration.auth_modules.any?
  end

  def auth_path(args = {})
    auth_modules_present? ? new_user_custom_session_path(args) : new_user_sessions_path(args)
  end

  def raise_user_not_signed_in
    redirect_to(
      auth_path,
      alert: I18n.t(i18n_key('user_not_signed_in_html'), place_name: current_site.organization_name, default: t('user.sessions.user_not_signed_in'))
    )
  end

  def raise_user_not_authorized
    redirect_to(
      request.referrer || user_root_path,
      alert: t('user.sessions.user_not_authorized')
    )
  end

  def raise_user_already_authenticated
    redirect_to(
      after_sign_in_path,
      alert: t('user.sessions.user_already_authenticated')
    )
  end

  private

  def i18n_key(key)
    "#{params[:controller].tr('/', '.')}.#{action_name}.#{key}"
  end
end
