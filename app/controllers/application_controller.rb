class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from ActionController::UnknownFormat, with: :render_404

  helper_method :helpers

  before_action :load_site

  def render_404
    render file: "public/404", status: 404, layout: false, handlers: [:erb], formats: [:html]
  end

  def helpers
    ActionController::Base.helpers
  end

  def choose_layout
    response.headers.delete "X-Frame-Options"
    # response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM http://some-origin.com"
    return 'gobierto_budgets_embedded' if params[:e].present?
    return 'gobierto_budgets_application'
  end

  def default_url_options(options={})
    if params[:e].present?
      { e: true }
    else
      {}
    end
  end

  protected

  def load_site
    unless Site.reserved_domain?(domain)
      @site = request.env['gobierto_site']
    end
  end

  def remote_ip
    env['action_dispatch.remote_ip'].calculate_ip
  end

  def domain
    @domain ||= (request.env['HTTP_HOST'] || request.env['SERVER_NAME'] || request.env['SERVER_ADDR']).split(':').first
  end
end
