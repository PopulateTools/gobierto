# frozen_string_literal: true

require "test_helper"

class ChangeLocaleTest < ActionDispatch::IntegrationTest
  attr_reader :site_with_different_locales

  def setup
    super
    @path = root_path
    @site_with_different_locales = sites(:cortegada)
    site_with_different_locales.configuration.available_locales = ["ca", "es"]
    site_with_different_locales.configuration.default_locale = "ca"
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_change_site_with_same_locale
    with_current_site(site) do
      visit @path
      within "div.language_selector" do
        click_link "ES"
      end

      within "nav.main-nav" do
        assert has_link?("Presupuestos")
      end
    end

    with_current_site(site_with_different_locales) do
      visit @path

      within "nav.main-nav" do
        assert has_link?("Presupuestos")
      end
    end
  end

  def test_change_site_with_different_locale
    with_current_site(site) do
      visit @path

      within "nav.main-nav" do
        assert has_link?("Budgets")
      end

    end

    with_current_site(site_with_different_locales) do
      visit @path

      within "nav.main-nav" do
        assert has_no_link?("Budgets")
        assert has_link?("Pressupostos")
      end
    end
  end
end
