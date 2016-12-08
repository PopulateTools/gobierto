require "test_helper"

class SiteTest < ActiveSupport::TestCase
  def site
    @site ||= sites(:madrid)
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
      assert_send [site, :initialize_admins]
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
end
