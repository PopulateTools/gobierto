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

  def site_with_data_module
    @site_with_data_module ||= sites(:madrid)
  end

  def test_navigation
    with_current_site(site) do
      visit @path

      within "nav.main-nav" do
        assert has_link?("Budgets")
        assert has_link?("Officials and Agendas")
        assert has_link?("CMS")
      end
    end
  end

  def test_navigation_with_data_module_frontend_enabled
    with_current_site(site_with_data_module) do
      visit @path

      within "nav.main-nav" do
        assert has_link?("Data")
      end

      site_with_data_module.gobierto_data_settings.frontend_disabled = true
      site_with_data_module.gobierto_data_settings.save

      visit @path

      within "nav.main-nav" do
        assert has_no_link?("Data")
      end
    end
  end
end
