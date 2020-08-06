# frozen_string_literal: true

module ApplicationConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_current_site, :set_locale, :authenticate_user_in_site
    around_action :set_locale_from_url
  end

  def current_site
    @current_site ||= begin
                        site = if request.env["gobierto_site"].present?
                                 request.env["gobierto_site"]
                               elsif Rails.env.test?
                                 Site.first
                               end
                        ::GobiertoCore::CurrentScope.current_site = site
                        site
                      end
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

  def authenticate_user_in_site
    if (Rails.env.production? || Rails.env.staging?) && @site && @site.password_protected?
      authenticate_or_request_with_http_basic("Gobierto") do |username, password|
        username == @site.configuration.password_protection_username && password == @site.configuration.password_protection_password
      end
    end
  end

  protected

  def remote_ip
    request.env["action_dispatch.remote_ip"].try(:calculate_ip) || request.remote_ip
  end

end
