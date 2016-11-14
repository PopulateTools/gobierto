require "test_helper"

class SiteTest < ActiveSupport::TestCase
  def site
    @site ||= sites(:madrid)
  end

  def test_valid
    assert site.valid?
  end

  def test_configuration
    assert_kind_of SiteConfiguration, site.configuration
  end
end
