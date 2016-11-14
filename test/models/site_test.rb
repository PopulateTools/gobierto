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

  def test_password_protected?
    refute site.password_protected?
    assert draft_site.password_protected?
  end

  def test_configuration
    assert_kind_of SiteConfiguration, site.configuration
  end
end
