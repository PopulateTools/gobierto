require "test_helper"

class Admin::SiteUpdateTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = edit_admin_site_path(site)
  end

  def admin
    @admin ||= admins(:nick)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_site_update
    with_signed_in_admin(admin) do
      visit @path

      within "form.edit_site" do
        fill_in "site_title", with: "Site Title"
        fill_in "site_name", with: "Site Name"
        fill_in "site_location_name", with: "Site Location"
        fill_in "site_domain", with: "test.gobierto.dev"
        fill_in "site_head_markup", with: "Site Head markup"
        fill_in "site_foot_markup", with: "Site Foot markup"
        fill_in "site_google_analytics_id", with: "UA-000000-01"

        within ".site-module-check-boxes" do
          check "Gobierto Development"
        end

        within ".site-visibility-level-radio-buttons" do
          choose "Active"
        end

        click_button "Update Site"
      end

      assert has_content?("Site was successfully updated.")

      within "table.site-list tbody tr#site-item-#{site.id}" do
        assert has_content?("Site Title")
        assert has_content?("Site Name")
      end
    end
  end

  def test_change_site_visibility_level
    with_signed_in_admin(admin) do
      visit admin_sites_path

      within "table.site-list tbody tr#site-item-#{site.id}" do
        assert has_content?("Active")
      end

      visit @path

      within "form.edit_site" do
        within ".site-visibility-level-radio-buttons" do
          choose "Draft"
          fill_in "site_username", with: "wadus"
          fill_in "site_password", with: "wadus"
        end

        click_button "Update Site"
      end

      within "table.site-list tbody tr#site-item-#{site.id}" do
        assert has_content?("Draft")
      end
    end
  end

  def test_change_site_visibility_level_without_credentials
    with_signed_in_admin(admin) do
      visit admin_sites_path

      within "table.site-list tbody tr#site-item-#{site.id}" do
        assert has_content?("Active")
      end

      visit @path

      within "form.edit_site" do
        within ".site-visibility-level-radio-buttons" do
          choose "Draft"
        end

        click_button "Update Site"
      end

      assert has_content?("Username can't be blank")
      assert has_content?("Password can't be blank")
    end
  end
end
