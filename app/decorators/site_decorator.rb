class SiteDecorator < BaseDecorator
  DOMAIN_URL_SCHEME = "http://"

  def initialize(site)
    @object = site
  end

  def to_s
    object.name
  end

  def domain_url
    if object.domain.starts_with?(DOMAIN_URL_SCHEME)
      object.domain
    else
      "#{DOMAIN_URL_SCHEME}#{object.domain}"
    end
  end
end
