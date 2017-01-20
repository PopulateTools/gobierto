require "test_helper"
require "support/file_uploader_helpers"

module GobiertoAdmin
  class SiteCreateTest < ActionDispatch::IntegrationTest
    include FileUploaderHelpers

    def setup
      super
      @path = new_admin_site_path
    end

    def admin
      @admin ||= gobierto_admin_admins(:nick)
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
          fill_in "site_links_markup", with: "Site Links markup"
          fill_in "site_google_analytics_id", with: "UA-000000-01"

          # Simulate Location selection in user control
          find("#site_municipality_id", visible: false).set("1")

          attach_file "site_logo_file", "test/fixtures/files/sites/logo-madrid.png"

          within ".site-module-check-boxes" do
            check "Gobierto Development"
          end

          within ".site-visibility-level-radio-buttons" do
            choose "Published"
          end

          with_stubbed_s3_file_upload do
            click_button "Create"
          end
        end

        assert has_message?("Site was successfully created")

        within "table.site-list tbody tr", match: :first do
          assert has_content?("Site Title")
          assert has_content?("Site Name")
          assert has_content?("Published")
        end
      end
    end
  end
end
