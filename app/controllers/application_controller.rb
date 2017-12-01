class ApplicationController < ActionController::Base
  include SubmodulesHelper
  include ::GobiertoCommon::ModuleHelper
  include ::GobiertoCommon::FileUploadHelper

  protect_from_forgery with: :exception

  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from ActionController::UnknownFormat, with: :render_404

  helper_method :helpers, :load_current_module_sub_sections, :current_site, :current_module, :current_module_body_class, :available_locales, :gobierto_people_event_preview_url, :page_preview_url

  before_action :set_current_site, :authenticate_user_in_site, :set_locale

  def render_404
    render file: "public/404", status: 404, layout: false, handlers: [:erb], formats: [:html]
  end

  def helpers
    ActionController::Base.helpers
  end

  def current_site
    @current_site ||= if request.env['gobierto_site'].present?
                        request.env['gobierto_site']
                      else
                        Site.first if Rails.env.test?
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

  def current_module_body_class
    if current_module == 'gobierto_participation'
      return 'gobierto_participation theme-participation'
    else
      return current_module
    end
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

  protected

  def remote_ip
    request.env['action_dispatch.remote_ip'].try(:calculate_ip) || request.remote_ip
  end

  def raise_module_not_enabled
    redirect_to(root_path) and return false
  end

  def gobierto_people_event_preview_url(event, options = {})
    options[:host] ||= current_site.domain
    # TODO
    return '#' if @person.nil? || !event.collection.container.is_a?(::GobiertoPeople::Person)

    if event.pending? || @person.draft?
      options.merge!(preview_token: current_admin.preview_token)
    end
    gobierto_people_person_event_url(@person.slug, event.slug, options)
  end

  def page_preview_url(page, options = {})
    options.merge!(preview_token: current_admin.preview_token) unless page.active?
    page.to_url(options)
  end

  def current_site_has_custom_template?(template_path)
    current_site_custom_template(template_path).any?
  end

  def current_site_custom_template(template_path)
    GobiertoCore::SiteTemplate.joins(:template).where("gcore_site_templates.site_id = ? AND gcore_templates.template_path = ?",
                                                      current_site.id, template_path)
  end
end
