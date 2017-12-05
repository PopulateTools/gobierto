# frozen_string_literal: true

require "test_helper"

class SiteNavigationTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = root_path
  end

  def site
    @site ||= sites(:santander)
  end

  def test_navigation
    with_current_site(site) do
      visit @path

      within ".main-nav" do
        assert has_link?("Budgets")
        assert has_link?("Officials and Agendas")
        assert has_link?("CMS")
      end
    end
  end
end
