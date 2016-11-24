require "test_helper"

class Admin::SiteCreateTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = new_admin_site_path
  end

  def admin
    @admin ||= admins(:nick)
  end

  def test_site_create
    with_signed_in_admin(admin) do
      visit @path

      within "form.new_site" do
        fill_in "site_title", with: "Site Title"
        fill_in "site_name", with: "Site Name"
        fill_in "site_location_name", with: "Site Location"
        fill_in "site_domain", with: "test.gobierto.dev"
        fill_in "site_head_markup", with: "Site Head markup"
        fill_in "site_foot_markup", with: "Site Foot markup"
        fill_in "site_google_analytics_id", with: "UA-000000-01"

        # Simulate Location selection in user control
        find("#site_municipality_id", visible: false).set("1")

        within ".site-module-check-boxes" do
          check "Gobierto Development"
        end

        within ".site-visibility-level-radio-buttons" do
          choose "Active"
        end

        click_button "Create Site"
      end

      assert has_content?("Site was successfully created.")

      within "table.site-list tbody tr", match: :first do
        assert has_content?("Site Title")
        assert has_content?("Site Name")
        assert has_content?("Active")
      end
    end
  end
end
