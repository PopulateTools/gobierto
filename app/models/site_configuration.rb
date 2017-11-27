class SiteConfiguration
  PROPERTIES = [
    :site_id,
    :modules,
    :logo,
    :demo,
    :password_protection_username,
    :password_protection_password,
    :google_analytics_id,
    :head_markup,
    :foot_markup,
    :links_markup,
    :available_locales,
    :default_locale,
    :privacy_page_id,
    :populate_data_api_token,
    :home_page,
    :home_page_item_id
  ].freeze

  DEFAULT_LOGO_PATH = "sites/logo-default.png".freeze

  MODULES_WITH_NOTIFICATONS = ["GobiertoPeople", "GobiertoBudgetConsultations"]

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

  def logo_with_fallback
    @logo || DEFAULT_LOGO_PATH
  end

  def available_locales
    return I18n.available_locales if @available_locales.nil? || @available_locales.empty?

    Array(default_locale).concat(@available_locales.select{ |l| l.present? }.map(&:to_s)).uniq
  end

  def default_locale
    @default_locale || I18n.default_locale
  end

  def privacy_page
    @privacy_page ||= GobiertoCms::Page.find_by(site_id: site_id, id: privacy_page_id) if site_id.present? && privacy_page_id.present?
  end

  def privacy_page?
    privacy_page.present?
  end

  def modules_with_notifications
    modules & MODULES_WITH_NOTIFICATONS
  end

  def default_modules
    [ 'GobiertoCms', 'GobiertoCalendars', 'GobiertoAttachments' ]
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
