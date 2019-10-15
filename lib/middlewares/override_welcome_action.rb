# frozen_string_literal: true

class OverrideWelcomeAction
  def initialize(app)
    @app = app
  end

  def call(env)
    # Load gobierto_site, used by route constraints
    full_domain = (env["HTTP_HOST"] || env["SERVER_NAME"] || env["SERVER_ADDR"]).split(":").first

    if site = Site.find_by_allowed_domain(full_domain)
      env["gobierto_site"] = site
    end

    if Rails.env.test? && site.nil?
      env["gobierto_site"] = ::GobiertoCore::CurrentScope.current_site || Site.first
    end

    # If the path is the homepage, the route should be the site root path
    if env["PATH_INFO"] == "/" && env["gobierto_site"].present?
      # A CMS page is handled by meta welcome controller
      if env["gobierto_site"].configuration.home_page != "GobiertoCms"
        env["PATH_INFO"] = env["gobierto_site"].root_path
        env["gobierto_welcome_override"] = true
      end
    end

    @app.call(env)
  end
end
