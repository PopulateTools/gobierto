# frozen_string_literal: true

module ApplicationConcern
  extend ActiveSupport::Concern

  BLOCKLIST_TRACKABLE_KEYS = %w(password password_confirmation authenticity_token utf8).freeze

  included do
    before_action :set_current_site, :set_locale
    around_action :set_locale_from_url
    after_action :track_request
  end

  def current_site
    GobiertoCore::CurrentScope.current_site
  end

  private

  def current_module?
    current_module.present?
  end

  def current_module
    @current_module ||= if params[:controller].include?("/")
                          params[:controller].split("/").first
                        end
  end

  def current_module_class
    @current_module_class ||= current_module&.camelize&.constantize
  end

  def set_current_site
    @site = current_site
  end

  def available_locales
    @available_locales ||= if current_site
                             current_site.configuration.available_locales
                           else
                             I18n.available_locales
                           end
  end

  def cache_key_preffix
    "site-#{current_site.id}-#{params.to_unsafe_h.sort.flatten.join("-")}"
  end

  def site_protected?
   (Rails.env.production? || Rails.env.staging?) && @site && @site.password_protected?
  end

  def authenticate_user_in_site
    if site_protected?
      authenticate_or_request_with_http_basic("Gobierto") do |username, password|
        username == @site.configuration.password_protection_username && password == @site.configuration.password_protection_password
      end
    end
  end

  def track_request
    return true if ignore_tracking_request?

    GobiertoCommon::EventCreatorJob.perform_later current_site.id, current_user&.id, current_visit&.id, filtered_params(request.params.merge(method: request.method))
  rescue StandardError => e
    Appsignal.send_error(e)
  end

  def ignore_tracking_request?
    Rails.env.development? || Rails.env.test?
  end

  protected

  def remote_ip
    request.env["action_dispatch.remote_ip"].try(:calculate_ip) || request.remote_ip
  end

  def filtered_params(params_hash)
    params_hash.with_indifferent_access.except(*BLOCKLIST_TRACKABLE_KEYS).transform_values do |v|
      next v unless v.is_a?(Hash)

      filtered_params(v)
    end
  end
end
