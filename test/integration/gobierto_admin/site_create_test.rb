# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class SiteCreateTest < ActionDispatch::IntegrationTest
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
          fill_in "site_title_translations_en", with: "Site Title"
          fill_in "site_name_translations_en", with: "Site Name"

          fill_in "site_title_translations_es", with: "Site Title"
          fill_in "site_name_translations_es", with: "Site Name"

          fill_in "site_location_name", with: "Site Location"
          fill_in "site_domain", with: "test.gobierto.dev"
          fill_in "site_head_markup", with: "Site Head markup"
          fill_in "site_foot_markup", with: "Site Foot markup"
          fill_in "site_links_markup", with: "Site Links markup"
          fill_in "site_google_analytics_id", with: "UA-000000-01"
          fill_in "site_populate_data_api_token", with: "APITOKEN"
          select "GobiertoPeople", from: "site_home_page"

          within ".site-check-boxes" do
            check "site_available_locales_es"
            choose "site_default_locale_es"
          end

          # Simulate Location selection in user control
          find("#site_municipality_id", visible: false).set("1")

          attach_file "site_logo_file", "test/fixtures/files/sites/logo-madrid.png"

          within ".site-module-check-boxes" do
            check "Gobierto Development"
          end

          within ".widget_save" do
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
