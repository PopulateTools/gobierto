require "test_helper"

class SiteTest < ActiveSupport::TestCase
  def site
    @site ||= sites(:madrid)
  end

  def test_valid
    assert site.valid?
  end
end
