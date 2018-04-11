# frozen_string_literal: true

require "test_helper"

class SiteTest < ActiveSupport::TestCase
  def setup
    super
    @module_seeder_spy = Spy.on(GobiertoCommon::GobiertoSeeder::ModuleSeeder, :seed)
    @module_site_seeder_spy = Spy.on(GobiertoCommon::GobiertoSeeder::ModuleSiteSeeder, :seed)
  end

  attr_reader :module_seeder_spy, :module_site_seeder_spy

  def first_call_arguments
    recipe_spy.calls.first.args
  end

  def site
    @site ||= sites(:madrid)
  end

  def organization_site
    @organization_site ||= sites(:organization_wadus)
  end

  def draft_site
    @draft_site ||= sites(:santander)
  end

  def test_valid
    assert site.valid?
  end

  # -- Initialization
  def test_admins_initialization
    site.admin_sites.delete_all

    assert_difference "site.admin_sites.size", 1 do
      site.send :initialize_admins
    end
  end

  # -- Configuration
  def test_configuration
    assert_kind_of SiteConfiguration, site.configuration
  end

  def test_password_protected?
    refute site.password_protected?
    assert draft_site.password_protected?
  end

  def test_place
    assert_kind_of INE::Places::Place, site.place
    assert site.place.present?
  end

  def test_place_when_organization_not_municipality
    assert_nil organization_site.place
  end

  def test_find_by_allowed_domain
    assert_equal site, Site.find_by_allowed_domain(site.domain)
    refute Site.find_by_allowed_domain("presupuestos." + ENV.fetch("HOST"))
    refute Site.find_by_allowed_domain("foo")
  end

  def test_seeder_called_after_create
    site = Site.new title: "Transparencia", name: "Albacete", domain: "albacete.gobierto.test",
                    organization_name: "Albacete", organization_id: INE::Places::Place.find_by_slug("albacete").id

    site.configuration_data = {
      "links_markup" => %(<a href="http://madrid.es">Ayuntamiento de Madrid</a>),
      "logo" => "http://www.madrid.es/assets/images/logo-madrid.png",
      "modules" => %w(GobiertoBudgets GobiertoBudgetConsultations GobiertoPeople),
      "locale" => "en",
      "google_analytics_id" => "UA-000000-01"
    }
    site.save!
    assert module_seeder_spy.has_been_called?
    assert module_site_seeder_spy.has_been_called?
    assert_equal ["GobiertoBudgets", site], module_seeder_spy.calls.first.args
    assert_equal ["gobierto_populate", "GobiertoBudgets", site], module_site_seeder_spy.calls.first.args
  end

  def test_seeder_called_after_modules_updated
    configuration_data = site.configuration_data
    configuration_data["modules"].push "GobiertoObservatory"
    site.configuration_data = configuration_data
    site.save!
    assert module_seeder_spy.has_been_called?
    assert module_site_seeder_spy.has_been_called?
    assert_equal ["GobiertoObservatory", site], module_seeder_spy.calls.first.args
    assert_equal ["gobierto_populate", "GobiertoObservatory", site], module_site_seeder_spy.calls.first.args
  end

  def test_invalid_if_municipality_blank
    site.organization_id = nil
    site.save
    assert site.errors.messages[:base].one?
  end
end
