module HttpCache
  extend ActiveSupport::Concern

  # Deliberately `private` rather than `public`: only the visitor's own browser
  # may store these responses. A shared cache (CDN, corporate proxy) must not,
  # because anonymous pages such as the sign-in form ship a session cookie and a
  # CSRF token that belong to one visitor. There is no HTML CDN in front of the
  # app today, so `public` would buy nothing in exchange for that risk.
  ANONYMOUS_MAX_AGE = 15.minutes

  def set_cache_headers
    if user_signed_in? || admin_authorized?
      response.headers["Cache-Control"] = "private"
    else
      response.headers["Cache-Control"] = "private, max-age=#{ANONYMOUS_MAX_AGE.to_i}"
      vary_by_cookie
    end
  rescue NoMethodError
    response.headers["Cache-Control"] = "private"
  end

  private

  # Everything that changes what an anonymous visitor should see lives in a
  # cookie, not in the URL: the locale (ApplicationController#set_locale) and the
  # session. Without this the browser would keep serving a page from before the
  # change -- most visibly, the home page would come back in the previous
  # language right after switching locale, since the nav links carry no locale
  # param. Signing in and signing out are covered by the same mechanism.
  def vary_by_cookie
    vary = response.headers["Vary"].to_s.split(",").map(&:strip)
    return if vary.include?("Cookie")

    response.headers["Vary"] = vary.push("Cookie").join(", ")
  end
end
