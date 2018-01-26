# frozen_string_literal: true

require "test_helper"

class SiteDecoratorTest < ActiveSupport::TestCase
  def setup
    super
    @subject = SiteDecorator.new(site)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_domain_url
    assert_equal "http://madrid.gobierto.test", @subject.domain_url
  end

  def test_domain_url_with_scheme
    site.stub(:domain, "http://wadus.gobierto.test") do
      assert_equal "http://wadus.gobierto.test", @subject.domain_url
    end
  end
end
