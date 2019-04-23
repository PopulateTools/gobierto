class SiteDecorator < BaseDecorator
  DOMAIN_URL_SCHEME = "http://"

  def initialize(site)
    @object = site
  end

  def to_s
    object.name
  end

  def organization_name
    @organization_name ||= object.organization_name
  end

  def determined_organization_name(determinative)
    I18n::Inflections::Base.create_with_locale(organization_name, gender: organization_name_gender).send(determinative)
  end

  def organization_name_gender
    if object.configuration.configuration_variables.has_key? "organization_name_gender"
      (object.configuration.configuration_variables["organization_name_gender"][I18n.locale.to_s] || :n).to_sym
    else
      :n
    end
  end

  def domain_url
    root_url = if object.domain.starts_with?(DOMAIN_URL_SCHEME)
                 object.domain
               else
                 "#{DOMAIN_URL_SCHEME}#{object.domain}"
               end

    root_url_path.present? ? URI.join(root_url, root_url_path).to_s : root_url
  end

  private

  def root_url_path
    ENV["GOBIERTO_ROOT_URL_PATH"]
  end

end
