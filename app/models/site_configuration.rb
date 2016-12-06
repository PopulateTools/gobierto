class SiteConfiguration
  PROPERTIES = [
    :modules,
    :logo,
    :links,
    :demo,
    :password_protection_username,
    :password_protection_password,
    :google_analytics_id,
    :head_markup,
    :foot_markup,
    :locale
  ]

  attr_accessor *PROPERTIES

  alias :site_modules :modules

  def initialize(configuration_params)
    return unless configuration_params.is_a?(Hash)

    PROPERTIES.each do |property|
      instance_variable_set("@#{property}", configuration_params[property.to_s])
    end
  end

  def modules
    return [] unless @modules.present?

    @modules.select { |site_module| SITE_MODULES.include?(site_module) }
  end

  def links
    @links || []
  end

  def locale
    @locale || I18n.default_locale
  end

  # Define question mark instance methods for each property.
  # i.e. `#demo?`.
  #
  PROPERTIES.each do |property|
    define_method "#{property}?" do
      send(property).present?
    end
  end

  # Define instance methods to check if a Site Module has been enabled.
  # i.e. `#gobierto_development_enabled?`.
  #
  SITE_MODULES.each do |site_module|
    define_method "#{site_module.underscore}_enabled?" do
      modules.include?(site_module)
    end
  end
end
