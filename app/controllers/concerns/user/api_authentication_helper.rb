# frozen_string_literal: true

module User::ApiAuthenticationHelper
  extend ActiveSupport::Concern

  included do
    if respond_to?(:helper_method)
      helper_method :current_user, :user_authenticated?
    end
  end

  private

  def current_user
    @current_user ||= find_current_user
  end

  def user_authenticated?
    current_user.present?
  end

  def authenticate_user!
    raise_unauthorized unless user_authenticated?
  end

  def find_current_user
    return unless token.present?

    current_site.users.confirmed.joins(:api_tokens).find_by(user_api_tokens: { token: token })
  end

  def raise_unauthorized
    render(json: { message: "Unauthorized" }, status: :unauthorized, adapter: :json_api) && return
  end

  def token
    @token = request.headers["token"] || params["token"]
  end
end
