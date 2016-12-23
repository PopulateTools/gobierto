require "test_helper"

class SiteConfigurationTest < ActiveSupport::TestCase
  def site_configuration
    @site_configuration ||= SiteConfiguration.new(site_configuration_params)
  end

  def test_not_whitelisted_properties
    assert_raises(NoMethodError) do
      site_configuration.wadus
    end
  end

  def test_modules
    assert_equal ["GobiertoDevelopment"], site_configuration.modules
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

  def test_demo
    assert_equal site_configuration_params["demo"], site_configuration.demo
  end

  def test_demo?
    assert site_configuration.demo?
  end

  def test_locale
    assert_equal site_configuration_params["locale"], site_configuration.locale
  end

  def test_locale?
    assert site_configuration.locale?
  end

  private

  def site_configuration_params
    @site_configuration_params ||= begin
      {
        "modules"      => ["Wadus", "GobiertoDevelopment"], # Note that the "Wadus" module is not standard
        "logo"         => "gobierto_development.png",
        "links_markup" => %Q{<a href="http://madrid.es">Ayuntamiento de Madrid</a>},
        "demo"         => true,
        "wadus"        => "wadus", # Note that this is not a whitelisted property
        "locale"       => :ca
      }
    end
  end
end
