# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class SessionTest < ActionDispatch::IntegrationTest
    def setup
      super
      @sign_in_path = new_admin_sessions_path
    end

    def site
      sites(:madrid)
    end

    def other_site
      sites(:santander)
    end

    def unmanaged_site
      sites(:huesca)
    end

    def admin
      @admin ||= gobierto_admin_admins(:tony)
    end

    def test_sign_in
      visit @sign_in_path

      fill_in :session_email, with: admin.email
      fill_in :session_password, with: "gobierto"

      click_button "Send"

      assert has_message?("Signed in successfully")

      click_link "admin-sign-out"

      assert has_message?("We need you to sign in to continue")
    end

    def test_invalid_sign_in
      visit @sign_in_path

      fill_in :session_email, with: admin.email
      fill_in :session_password, with: "wadus"

      click_button "Send"

      assert has_message?("The data you entered doesn't seem to be valid. Please try again.")
    end

    def test_disabled_sign_in
      visit @sign_in_path

      admin.disabled!

      fill_in :session_email, with: admin.email
      fill_in :session_password, with: "gobierto"

      click_button "Send"

      assert has_message?("The data you entered doesn't seem to be valid. Please try again.")
    end

    def test_sign_in_when_already_signed_in
      with_signed_in_admin(admin) do
        visit @sign_in_path

        assert has_message?("You are already signed in")
      end
    end

    def test_sign_in_mantains_session_across_sites
      with_current_site_with_host(site) do
        sign_in_admin(admin)
        assert_equal site.name, find('div#current-site-name').text
      end

      with_current_site_with_host(other_site) do
        visit @sign_in_path

        assert has_message?("You are already signed in")
        assert_equal other_site.name, find('div#current-site-name').text
      end
    end

    def test_sign_in_with_domain
      with_site_host(site) do
        sign_in_admin(admin)
        assert_equal site.name, find('div#current-site-name').text
        click_link "admin-sign-out"
      end

      with_site_host(other_site) do
        sign_in_admin(admin)
        assert_equal other_site.name, find('div#current-site-name').text
        click_link "admin-sign-out"
      end

      with_site_host(unmanaged_site) do
        sign_in_admin(admin)
        assert_includes admin.sites.map(&:name), find('div#current-site-name').text
        refute_equal unmanaged_site.name, find('div#current-site-name').text
        click_link "admin-sign-out"
      end

      sign_in_admin(admin)
      assert_includes admin.sites.map(&:name), find('div#current-site-name').text
      click_link "admin-sign-out"
    end

    def test_sign_out
      with_current_site_with_host(site) do
        sign_in_admin(admin)
      end

      with_current_site_with_host(site) do
        visit admin_root_path
        click_link "admin-sign-out"
        visit @sign_in_path

        assert has_content?("Log in")
      end

      with_current_site_with_host(other_site) do
        visit @sign_in_path

        assert has_content?("Log in")
      end
    end
  end
end
