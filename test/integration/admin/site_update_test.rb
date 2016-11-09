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

        within ".site-module-check-boxes" do
          check "Gobierto Development"
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
end
