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
      GobiertoCore::CurrentScope.current_site = site
    end

    if Rails.env.test? && site.nil?
      GobiertoCore::CurrentScope.current_site ||= Site.first
      env["gobierto_site"] = GobiertoCore::CurrentScope.current_site
    end

    # If the path is the homepage, the route should be the site root path
    if env["PATH_INFO"] == "/" && env["gobierto_site"].present?
      # A CMS page is handled by meta welcome controller
      home_page_module = env["gobierto_site"].configuration.home_page
      if home_page_module != "GobiertoCms"
        # GobiertoPeople has translations in paths, and the value in the cookie
        # is overrided
        I18n.locale = env["gobierto_site"].configuration.default_locale if home_page_module == "GobiertoPeople"
        env["PATH_INFO"] = env["gobierto_site"].root_path
        env["gobierto_welcome_override"] = true
      end
    end

    @app.call(env)
  end
end
