class ApplicationController < ActionController::Base
  include SubmodulesHelper
  include ::GobiertoCommon::ModuleHelper
  include ::GobiertoCommon::FileUploadHelper
  include ::GobiertoCms::GlobalNavigation

  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::UnknownFormat, with: :render_404

  helper_method(
    :helpers,
    :load_current_module_sub_sections,
    :current_site,
    :current_module,
    :current_module_class,
    :available_locales,
    :algoliasearch_configured?,
    :cache_key_preffix
  )

  before_action :set_current_site, :authenticate_user_in_site, :set_locale, :apply_engines_overrides

  def render_404
    render file: "public/404", status: 404, layout: false, handlers: [:erb], formats: [:html]
  end

  def helpers
    ActionController::Base.helpers
  end

  def current_site
    @current_site ||= begin
      site = if request.env['gobierto_site'].present?
        request.env['gobierto_site']
      else
        Site.first if Rails.env.test?
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
    @current_module ||= if params[:controller].include?('/')
                          params[:controller].split('/').first
                        end
  end

  def current_module_class
    @current_module_class ||= current_module&.camelize&.constantize
  end

  def set_current_site
    @site = current_site
  end

  def authenticate_user_in_site
    if (Rails.env.production? || Rails.env.staging?) && @site && @site.password_protected?
      authenticate_or_request_with_http_basic('Gobierto') do |username, password|
        username == @site.configuration.password_protection_username && password == @site.configuration.password_protection_password
      end
    end
  end

  def set_locale
    locale_param = params[:locale]
    locale_cookie = cookies.signed[:locale]
    site_locale = current_site.configuration.default_locale if current_site.present?

    preferred_locale = (locale_param || locale_cookie || site_locale || I18n.default_locale).to_s

    if available_locales.include?(preferred_locale)
      I18n.locale = cookies.permanent.signed[:locale] = preferred_locale.to_sym
    end
  end

  def available_locales
    @available_locales ||= if current_site
                             current_site.configuration.available_locales
                           else
                             I18n.available_locales
                           end
  end

  def algoliasearch_configured?
    ::GobiertoCommon::Search.algoliasearch_configured?
  end

  def engine_overrides
    @engine_overrides ||= current_site.try(:engines_overrides)
  end

  def engine_overrides?
    engine_overrides.present?
  end

  def apply_engines_overrides
    return unless engine_overrides?
    engine_overrides.each do |engine|
      prepend_view_path Rails.root.join("vendor/gobierto_engines/#{ engine }/app/views")
    end
  end

  def cache_key_preffix
    "site-#{current_site.id}-#{params.to_unsafe_h.sort.flatten.join('-')}"
  end

  protected

  def remote_ip
    request.env['action_dispatch.remote_ip'].try(:calculate_ip) || request.remote_ip
  end

  def raise_module_not_enabled(redirect = true)
    if redirect
      redirect_to(root_path) and return false
    else
      head :forbidden
    end
  end
end
