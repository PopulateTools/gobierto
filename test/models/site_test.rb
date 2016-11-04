require "test_helper"

class SiteTest < ActiveSupport::TestCase
  def site
    @site ||= sites(:acme)
  end

  def test_valid
    assert site.valid?
  end
end
