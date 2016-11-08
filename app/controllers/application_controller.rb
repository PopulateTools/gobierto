class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from ActionController::UnknownFormat, with: :render_404

  helper_method :helpers, :load_current_module_sub_sections, :current_site

  before_action :set_current_site, :authenticate_user_in_site

  def render_404
    render file: "public/404", status: 404, layout: false, handlers: [:erb], formats: [:html]
  end

  def helpers
    ActionController::Base.helpers
  end

  # TODO: check if we still need this
  def default_url_options(options={})
    if params[:e].present?
      { e: true }
    else
      {}
    end
  end

  def load_current_module_sub_sections
    if current_module?
      if lookup_context.exists?("#{current_module}/layouts/_menu_subsections.html.erb")
        render partial: "#{current_module}/layouts/menu_subsections"
      end
    end
  end

  def current_site
    request.env['gobierto_site'] unless Site.reserved_domain?(domain)
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

  def set_current_site
    @site = current_site
  end

  def authenticate_user_in_site
    if Rails.env.production? && @site && @site.password_protected?
      authenticate_or_request_with_http_basic('Gobierto Site') do |username, password|
        username == @site.configuration.password_protection_username && password == @site.configuration.password_protection_password
      end
    end
  end

  protected

  def remote_ip
    env['action_dispatch.remote_ip'].calculate_ip
  end

  def domain
    @domain ||= (request.env['HTTP_HOST'] || request.env['SERVER_NAME'] || request.env['SERVER_ADDR']).split(':').first
  end
end
