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

      within "form.new_site_form" do
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

      assert has_content?("Site was successfully created.")

      within "table.site-list tbody tr", match: :first do
        assert has_content?("Site Title")
        assert has_content?("Site Name")
        assert has_content?("Active")
      end
    end
  end
end
