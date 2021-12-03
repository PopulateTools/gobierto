# frozen_string_literal: true

class ApiBaseController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include SubmodulesHelper
  include ::GobiertoCommon::ModuleHelper
  include ApplicationConcern
  include ::User::ApiAuthenticationHelper
  include HttpCache
  include LogrageHost

  before_action :disable_cors, :check_host, :authenticate_in_site, :set_cache_headers

  rescue_from ActiveRecord::RecordNotFound, with: -> { send_not_found }

  def preferred_locale
    @preferred_locale ||= begin
                            locale_param = params[:locale]
                            site_locale = current_site.configuration.default_locale if current_site.present?
                            (locale_param || site_locale || I18n.default_locale).to_s
                          end
  end

  def set_locale
    if available_locales.include?(preferred_locale)
      I18n.locale = preferred_locale.to_sym
    end
  end

  protected

  def api_errors_render(item, options = {})
    render({ json: item, status: :unprocessable_entity, serializer: ActiveModel::Serializer::ErrorSerializer }.merge(options))
  end

  def send_unauthorized(options = {})
    message = options.delete(:message) || "Unauthorized"
    render(json: { message: message }, status: :unauthorized, adapter: :json_api) && return
  end

  def send_not_found(options = {})
    message = options.delete(:message) || "Not found"
    render(json: { message: message }, status: :not_found, adapter: :json_api) && return
  end

  def raise_module_not_enabled(_redirect)
    head :forbidden
  end

  def raise_module_not_allowed
    send_unauthorized(message: "Module not allowed")
  end

  def disable_cors
    response.set_header("Access-Control-Allow-Origin", "*")
    response.set_header("Access-Control-Request-Method", "*")
  end
end
