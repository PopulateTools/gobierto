# frozen_string_literal: true

require "test_helper"

class SiteHelperTest < ActionView::TestCase

  include SiteHelper

  def madrid
    @madrid ||= sites(:madrid)
  end

  def santander
    @santander ||= sites(:santander)
  end

  attr_reader :current_site

  def test_custom_favicon_url
    @current_site = madrid
    assert_nil custom_favicon_url
    @current_site = santander
    assert_equal "https://populate.tools/favicon.ico", custom_favicon_url
  end

end
