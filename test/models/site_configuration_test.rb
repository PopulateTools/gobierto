# frozen_string_literal: true

require "test_helper"

class SiteConfigurationTest < ActiveSupport::TestCase
  def site_configuration
    @site_configuration ||= SiteConfiguration.new(site_configuration_params)
  end

  def site
    @site = sites(:madrid)
  end

  def page
    @page ||= gobierto_cms_pages(:privacy)
  end

  def test_not_whitelisted_properties
    assert_raises(NoMethodError) do
      site_configuration.wadus
    end
  end

  def test_modules
    assert_equal ["GobiertoDevelopment"], site_configuration.modules
  end

  def test_available_modules?
    assert site_configuration.available_module?("GobiertoDevelopment")
  end

  def test_modules?
    assert site_configuration.modules?
  end

  def test_logo
    assert_equal site_configuration_params["logo"], site_configuration.logo
  end

  def test_logo?
    assert site_configuration.logo?
  end

  def test_links_markup
    assert_equal site_configuration_params["links_markup"], site_configuration.links_markup
  end

  def test_links_markup?
    assert site_configuration.links_markup?
  end

  def test_admin_custom_code
    assert_equal site_configuration_params["admin_custom_code"], site_configuration.admin_custom_code
  end

  def test_admin_custom_code?
    assert site_configuration.admin_custom_code?
  end

  def test_demo
    assert_equal site_configuration_params["demo"], site_configuration.demo
  end

  def test_demo?
    assert site_configuration.demo?
  end

  def test_default_locale
    assert_equal site_configuration_params["default_locale"], site_configuration.default_locale
  end

  def test_default_locale?
    assert site_configuration.default_locale?
  end

  def test_available_locales
    assert_equal site_configuration_params["available_locales"], site_configuration.available_locales
  end

  def test_logo_with_fallback_when_logo_is_present
    assert_equal site_configuration_params["logo"], site_configuration.logo_with_fallback
  end

  def test_logo_with_fallback_when_logo_is_not_present
    site_configuration_params["logo"] = nil
    site_configuration = SiteConfiguration.new(site_configuration_params)

    assert_equal SiteConfiguration::DEFAULT_LOGO_PATH, site_configuration.logo_with_fallback
  end

  def test_privacy_page
    assert_equal page, site_configuration.privacy_page
    assert site_configuration.privacy_page?
  end

  def test_configuration_variables
    assert_equal "bar", site_configuration.configuration_variables["foo"]
  end

  private

  def site_configuration_params
    @site_configuration_params ||= begin
      {
        "modules"           => ["Wadus", "GobiertoDevelopment"], # Note that the "Wadus" module is not standard
        "logo"              => "gobierto_development.png",
        "links_markup"      => %(<a href="http://madrid.es">Ayuntamiento de Madrid</a>),
        "admin_custom_code" => %(<div class="main clearfix"><div class="pure-menu-link">Hello!</div></div>),
        "demo"              => true,
        "wadus"             => "wadus", # Note that this is not a whitelisted property
        "default_locale"    => "ca",
        "available_locales" => %w(ca es),
        "site_id"           => site.id,
        "privacy_page_id"   => page.id,
        "raw_configuration_variables" => <<-YAML
foo: bar
YAML
      }
    end
  end
end
