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

      within "form.edit_site_form" do
        fill_in "Title", with: "Site Title"
        fill_in "Name", with: "Site Name"
        fill_in "Location name", with: "Site Location"
        fill_in "Domain", with: "test.gobierto.dev"
        fill_in "Head markup", with: "Site Head markup"
        fill_in "Foot markup", with: "Site Foot markup"
        fill_in "Google analytics", with: "UA-000000-01"

        within ".site-module-check-boxes" do
          check "Gobierto Development"
        end

        within ".site-visibility-level-radio-buttons" do
          choose "Active"
        end

        click_button "Save"
      end

      assert has_content?("Site was successfully updated.")

      within "table.site-list tbody" do
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

      within "form.edit_site_form" do
        within ".site-visibility-level-radio-buttons" do
          choose "Draft"
        end

        click_button "Save"
      end

      within "table.site-list tbody tr#site-item-#{site.id}" do
        assert has_content?("Draft")
      end
    end
  end
end
