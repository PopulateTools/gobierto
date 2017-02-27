require "test_helper"
require "support/file_uploader_helpers"

module GobiertoAdmin
  class SiteUpdateTest < ActionDispatch::IntegrationTest
    include FileUploaderHelpers

    def setup
      super
      @path = edit_admin_site_path(site)
    end

    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def site
      @site ||= sites(:madrid)
    end

    def privacy_page
      @privacy_page ||= gobierto_cms_pages(:privacy)
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
          fill_in "site_links_markup", with: "Site Links markup"
          fill_in "site_google_analytics_id", with: "UA-000000-01"

          attach_file "site_logo_file", "test/fixtures/files/sites/logo-madrid.png"

          within ".site-module-check-boxes" do
            check "Gobierto Development"
          end

          within ".site-visibility-level-radio-buttons" do
            choose "Published"
          end

          select privacy_page.title, from: "site_privacy_page_id"

          with_stubbed_s3_file_upload do
            click_button "Update"
          end
        end

        assert has_message?("Site was successfully updated")

        within "form.edit_site" do
          assert has_field?("site_name", with: "Site Name")
          assert has_field?("site_title", with: "Site Title")
          assert has_field?("site_location_name", with: "Site Location")
          assert has_field?("site_domain", with: "test.gobierto.dev")
          assert has_field?("site_head_markup", with: "Site Head markup")
          assert has_field?("site_foot_markup", with: "Site Foot markup")
          assert has_field?("site_links_markup", with: "Site Links markup")
          assert has_field?("site_google_analytics_id", with: "UA-000000-01")
          assert has_select?("Privacy page", selected: privacy_page.title)

          within ".site-module-check-boxes" do
            assert has_checked_field?("Gobierto Development")
          end

          within ".site-visibility-level-radio-buttons" do
            assert has_checked_field?("Published")
          end
        end
      end
    end

    def test_change_site_visibility_level
      with_signed_in_admin(admin) do
        visit admin_sites_path

        within "table.site-list tbody tr#site-item-#{site.id}" do
          assert has_content?("Published")
        end

        visit @path

        within "form.edit_site" do
          within ".site-visibility-level-radio-buttons" do
            choose "Draft"
            fill_in "site_username", with: "wadus"
            fill_in "site_password", with: "wadus"
          end

          click_button "Update"
        end

        assert has_message?("Site was successfully updated")

        within "form.edit_site" do
          within ".site-visibility-level-radio-buttons" do
            assert has_checked_field?("Draft")
          end

          fill_in "site_title", with: "New Site Title"
          click_button "Update"
        end

        assert has_message?("Site was successfully updated")
      end
    end

    def test_change_site_visibility_level_without_credentials
      with_signed_in_admin(admin) do
        visit admin_sites_path

        within "table.site-list tbody tr#site-item-#{site.id}" do
          assert has_content?("Published")
        end

        visit @path

        within "form.edit_site" do
          within ".site-visibility-level-radio-buttons" do
            choose "Draft"
          end

          click_button "Update"
        end

        assert has_content?("Username can't be blank")
        assert has_content?("Password can't be blank")
      end
    end
  end
end
