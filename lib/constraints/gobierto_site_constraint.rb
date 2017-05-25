# frozen_string_literal: true

class GobiertoSiteConstraint
  def matches?(request)
    full_domain = (request.env['HTTP_HOST'] || request.env['SERVER_NAME'] || request.env['SERVER_ADDR']).split(':').first

    if site = Site.find_by(allowed_domain: full_domain)
      request.env['gobierto_site'] = site
      return true
    end

    false
  end
end
