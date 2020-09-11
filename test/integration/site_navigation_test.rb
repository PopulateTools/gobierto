# frozen_string_literal: true

require "test_helper"

class SiteNavigationTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = root_path
  end

  def password_protected_site
    @password_protected_site ||= sites(:santander)
  end

  def site_with_data_module
    @site_with_data_module ||= sites(:madrid)
  end

  def test_navigation_without_password
    Rails.stub(:env, ActiveSupport::StringInquirer.new("production")) do
      with_current_site(password_protected_site) do
        visit @path
        assert has_content?("HTTP Basic: Access denied.")
      end
    end
  end

  def test_navigation_with_basic_auth
    Rails.stub(:env, ActiveSupport::StringInquirer.new("production")) do
      with_current_site(password_protected_site) do
        Capybara.current_session.driver.browser.basic_authorize(
          password_protected_site.configuration.password_protection_username,
          password_protected_site.configuration.password_protection_password
        )
        visit gobierto_people_root_path

        within "nav.main-nav" do
          assert has_link?("Budgets")
          assert has_link?("Officials and Agendas")
          assert has_link?("CMS")
        end
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
